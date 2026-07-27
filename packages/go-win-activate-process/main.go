package main

import (
	"fmt"
	"os"
	"path/filepath"
	"strings"
	"syscall"
	"unsafe"

	"golang.org/x/sys/windows"
)

const childEnvVar = "WIN_ACTIVATE_CHILD"

var (
	modUser32   = windows.NewLazySystemDLL("user32.dll")
	modKernel32 = windows.NewLazySystemDLL("kernel32.dll")
	modShell32  = windows.NewLazySystemDLL("shell32.dll")
	modOle32    = windows.NewLazySystemDLL("ole32.dll")

	procEnumWindows          = modUser32.NewProc("EnumWindows")
	procGetWindowTextW       = modUser32.NewProc("GetWindowTextW")
	procGetWindowTextLengthW = modUser32.NewProc("GetWindowTextLengthW")
	procSetForegroundWindow  = modUser32.NewProc("SetForegroundWindow")
	procGetWindowPlacement   = modUser32.NewProc("GetWindowPlacement")
	procShowWindow           = modUser32.NewProc("ShowWindow")
	procIsWindowVisible      = modUser32.NewProc("IsWindowVisible")
	procGetModuleFileNameW   = modKernel32.NewProc("GetModuleFileNameW")
	procShellExecuteExW      = modShell32.NewProc("ShellExecuteExW")
	procCoInitialize         = modOle32.NewProc("CoInitialize")
	procCoCreateInstance     = modOle32.NewProc("CoCreateInstance")
	procCoUninitialize       = modOle32.NewProc("CoUninitialize")
)

var (
	CLSID_VirtualDesktopManager = newGUID("{aa509086-5ca9-4c25-8f95-589d3c07b48a}")
	IID_IVirtualDesktopManager  = newGUID("{a5cd92ff-29be-454c-8d04-d82879fb3f1b}")
)

// newGUID は文字列から GUID 構造体に変換します。
func newGUID(s string) *windows.GUID {
	guid, err := windows.GUIDFromString(s)
	if err != nil {
		panic(fmt.Sprintf("GUIDFromString failed: %v", err))
	}
	return &guid
}

type IVirtualDesktopManagerVtbl struct {
	QueryInterface                  uintptr
	AddRef                          uintptr
	Release                         uintptr
	IsWindowOnCurrentVirtualDesktop uintptr
	GetWindowDesktopId              uintptr
	MoveWindowToDesktop             uintptr
}

type IVirtualDesktopManager struct {
	LpVtbl *IVirtualDesktopManagerVtbl
}

type windowPlacement struct {
	Length   uint32
	Flags    uint32
	ShowCmd  uint32
	PtMinPos struct{ X, Y int32 }
	PtMaxPos struct{ X, Y int32 }
	RcNormal struct{ Left, Top, Right, Bottom int32 }
}

const (
	swShowMaximized       = 3
	swShowNormal          = 1
	swHide                = 0
	seeMaskNocloseprocess = 0x00000040
)

type shellExecuteInfo struct {
	CbSize     uint32
	FMask      uint32
	Hwnd       uintptr
	Verb       *uint16
	File       *uint16
	Parameters *uint16
	Directory  *uint16
	Show       int32
	InstApp    uintptr
	IDList     uintptr
	Class      *uint16
	HkeyClass  uintptr
	HotKey     uint32
	HIcon      uintptr
	HProcess   uintptr
}

func main() {
	if len(os.Args) != 2 {
		fmt.Fprintf(os.Stderr, "usage: %s <WindowTitle>\n", filepath.Base(os.Args[0]))
		os.Exit(1)
	}

	searchTitle := os.Args[1]

	// 子プロセスかどうかをチェック
	if os.Getenv(childEnvVar) == "" {
		// 親プロセス: 自分自身を子プロセスとして再実行
		if err := relaunchAsChild(); err != nil {
			fmt.Fprintf(os.Stderr, "failed to relaunch: %v\n", err)
			os.Exit(1)
		}
		return
	}

	hr, _, _ := procCoInitialize.Call(0)
	if hr != 0 && hr != 0x00000001 { // S_OK or S_FALSE(already initialized)
		fmt.Fprintf(os.Stderr, "CoInitialize failed: 0x%x\n", hr)
		os.Exit(1)
	}
	defer procCoUninitialize.Call()

	var vdm *IVirtualDesktopManager
	hr, _, _ = procCoCreateInstance.Call(
		uintptr(unsafe.Pointer(CLSID_VirtualDesktopManager)),
		0,
		1, // CLSCTX_INPROC_SERVER
		uintptr(unsafe.Pointer(IID_IVirtualDesktopManager)),
		uintptr(unsafe.Pointer(&vdm)),
	)
	if hr == 0 && vdm != nil { // S_OK
		defer syscall.Syscall(vdm.LpVtbl.Release, 1, uintptr(unsafe.Pointer(vdm)), 0, 0)
	} else {
		// IVirtualDesktopManager が取得できなくても、フォールバックして動作するようにする
		vdm = nil
	}

	hwnd := findWindowByTitle(searchTitle, vdm)
	if hwnd == 0 {
		fmt.Fprintf(os.Stderr, "window not found: %s\n", searchTitle)
		os.Exit(1)
	}

	activateWindow(hwnd)
}

// 自分自身を子プロセスとして再実行する
//
// WSL で tmux のサーバプロセスがバックグラウンド実行されているときに、
// win32 の exe を直接実行してもウィンドウをフォアグラウンド化できない
//
// https://learn.microsoft.com/ja-jp/windows/win32/api/winuser/nf-winuser-setforegroundwindow
// 呼び出し元プロセスが、フォアグラウンドプロセスから起動されたプロセスにならないため
//
// ShellExecuteEx を挟むとこの制限が突破できる。これは Windows Shell を通じてプロセスが起動されるため
// （具体的な理由は不明）
func relaunchAsChild() error {
	// 自分自身の実行ファイルパスを取得
	exePath, err := getModuleFileName()
	if err != nil {
		return fmt.Errorf("GetModuleFileNameW: %w", err)
	}

	// 環境変数を設定（子プロセスに継承される）
	os.Setenv(childEnvVar, "1")

	// ShellExecuteEx で起動
	exePathPtr, _ := syscall.UTF16PtrFromString(exePath)
	params := fmt.Sprintf(`"%s"`, os.Args[1])
	paramsPtr, _ := syscall.UTF16PtrFromString(params)

	var sei shellExecuteInfo
	sei.CbSize = uint32(unsafe.Sizeof(sei))
	sei.FMask = seeMaskNocloseprocess
	sei.File = exePathPtr
	sei.Parameters = paramsPtr
	sei.Show = swHide

	ret, _, err := procShellExecuteExW.Call(uintptr(unsafe.Pointer(&sei)))
	if ret == 0 {
		return fmt.Errorf("ShellExecuteExW: %w", err)
	}

	// ハンドルをクローズ
	if sei.HProcess != 0 {
		windows.CloseHandle(windows.Handle(sei.HProcess))
	}

	return nil
}

// 自分自身の実行ファイルパスを取得する
func getModuleFileName() (string, error) {
	buf := make([]uint16, windows.MAX_PATH)
	ret, _, err := procGetModuleFileNameW.Call(
		0,
		uintptr(unsafe.Pointer(&buf[0])),
		uintptr(len(buf)),
	)
	if ret == 0 {
		return "", err
	}
	return syscall.UTF16ToString(buf), nil
}

// タイトルの部分一致でウィンドウを検索する
func findWindowByTitle(searchTitle string, vdm *IVirtualDesktopManager) uintptr {
	var currentDesktopHwnd uintptr
	var otherDesktopHwnd uintptr
	searchLower := strings.ToLower(searchTitle)

	cb := syscall.NewCallback(func(hwnd uintptr, _ uintptr) uintptr {
		if !isWindowVisible(hwnd) {
			return 1 // continue
		}

		title := getWindowText(hwnd)
		if !strings.Contains(strings.ToLower(title), searchLower) {
			return 1 // continue
		}

		if vdm != nil {
			var isOnCurrent int32
			hr, _, _ := syscall.Syscall(vdm.LpVtbl.IsWindowOnCurrentVirtualDesktop, 3, uintptr(unsafe.Pointer(vdm)), hwnd, uintptr(unsafe.Pointer(&isOnCurrent)))

			if hr == 0 { // S_OK
				if isOnCurrent != 0 {
					// 現在のデスクトップで見つかったので、これを最優先して探索終了
					currentDesktopHwnd = hwnd
					return 0 // stop enumeration
				} else {
					// 他のデスクトップで見つかった。探索は続けるが、最初の候補として保持
					if otherDesktopHwnd == 0 {
						otherDesktopHwnd = hwnd
					}
				}
			} else { // COM call failed
				// 他のデスクトップで見つかったものとして扱う
				if otherDesktopHwnd == 0 {
					otherDesktopHwnd = hwnd
				}
			}
		} else { // vdm is nil
			// 仮想デスクトップ管理が利用できない場合、最初に見つかったもので終了
			currentDesktopHwnd = hwnd
			return 0 // stop enumeration
		}

		return 1 // continue
	})

	procEnumWindows.Call(cb, 0)

	if currentDesktopHwnd != 0 {
		return currentDesktopHwnd
	}
	return otherDesktopHwnd
}

func isWindowVisible(hwnd uintptr) bool {
	ret, _, _ := procIsWindowVisible.Call(hwnd)
	return ret != 0
}

// ウィンドウのタイトルを取得する
func getWindowText(hwnd uintptr) string {
	length, _, _ := procGetWindowTextLengthW.Call(hwnd)
	if length == 0 {
		return ""
	}

	buf := make([]uint16, length+1)
	procGetWindowTextW.Call(hwnd, uintptr(unsafe.Pointer(&buf[0])), uintptr(len(buf)))
	return syscall.UTF16ToString(buf)
}

// ウィンドウをアクティブ化する
func activateWindow(hwnd uintptr) {
	// 現在の状態を取得
	var wp windowPlacement
	wp.Length = uint32(unsafe.Sizeof(wp))
	procGetWindowPlacement.Call(hwnd, uintptr(unsafe.Pointer(&wp)))

	// 最小化されていたら元に戻す
	if wp.ShowCmd == 2 { // SW_SHOWMINIMIZED
		procShowWindow.Call(hwnd, swShowNormal)
	}

	// 前面に持ってくる
	procSetForegroundWindow.Call(hwnd)

	// 最大化状態だった場合は最大化を維持
	if wp.ShowCmd == swShowMaximized {
		procShowWindow.Call(hwnd, swShowMaximized)
	}
}
