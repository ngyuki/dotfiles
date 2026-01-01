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

	procEnumWindows          = modUser32.NewProc("EnumWindows")
	procGetWindowTextW       = modUser32.NewProc("GetWindowTextW")
	procGetWindowTextLengthW = modUser32.NewProc("GetWindowTextLengthW")
	procSetForegroundWindow  = modUser32.NewProc("SetForegroundWindow")
	procGetWindowPlacement   = modUser32.NewProc("GetWindowPlacement")
	procShowWindow           = modUser32.NewProc("ShowWindow")
	procGetModuleFileNameW   = modKernel32.NewProc("GetModuleFileNameW")
	procShellExecuteExW      = modShell32.NewProc("ShellExecuteExW")
)

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

	// 子プロセス: ウィンドウをアクティブ化
	hwnd := findWindowByTitle(searchTitle)
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
// PowerShell の Start-Process を挟むとこの制限が突破できる
// これは内部で ShellExecuteEx を使っていて Windows Shell を通じてプロセスが起動されるため
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
func findWindowByTitle(searchTitle string) uintptr {
	var found uintptr
	searchLower := strings.ToLower(searchTitle)

	cb := syscall.NewCallback(func(hwnd uintptr, _ uintptr) uintptr {
		title := getWindowText(hwnd)
		if title == "" {
			return 1 // continue
		}

		if strings.Contains(strings.ToLower(title), searchLower) {
			found = hwnd
			return 0 // stop enumeration
		}
		return 1 // continue
	})

	procEnumWindows.Call(cb, 0)
	return found
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
