package main

import (
	"encoding/base64"
	"encoding/json"
	"flag"
	"fmt"
	"net/url"
	"os"
	"os/exec"
	"path/filepath"
	"regexp"
	"strings"
	"syscall"
	"unsafe"

	"golang.org/x/sys/windows"
	"golang.org/x/sys/windows/registry"
)

const childEnvVar = "WIN_ACTIVATE_OPTS"
const PROCESS_QUERY_LIMITED_INFORMATION = 0x1000

var (
	modUser32   = windows.NewLazySystemDLL("user32.dll")
	modKernel32 = windows.NewLazySystemDLL("kernel32.dll")
	modShell32  = windows.NewLazySystemDLL("shell32.dll")
	modOle32    = windows.NewLazySystemDLL("ole32.dll")

	procEnumWindows                = modUser32.NewProc("EnumWindows")
	procGetWindowTextW             = modUser32.NewProc("GetWindowTextW")
	procGetWindowTextLengthW       = modUser32.NewProc("GetWindowTextLengthW")
	procGetClassNameW              = modUser32.NewProc("GetClassNameW")
	procGetWindowThreadProcessId   = modUser32.NewProc("GetWindowThreadProcessId")
	procSetForegroundWindow        = modUser32.NewProc("SetForegroundWindow")
	procGetWindowPlacement         = modUser32.NewProc("GetWindowPlacement")
	procShowWindow                 = modUser32.NewProc("ShowWindow")
	procIsWindowVisible            = modUser32.NewProc("IsWindowVisible")
	procGetModuleFileNameW         = modKernel32.NewProc("GetModuleFileNameW")
	procOpenProcess                = modKernel32.NewProc("OpenProcess")
	procQueryFullProcessImageNameW = modKernel32.NewProc("QueryFullProcessImageNameW")
	procShellExecuteExW            = modShell32.NewProc("ShellExecuteExW")
	procCoInitialize               = modOle32.NewProc("CoInitialize")
	procCoCreateInstance           = modOle32.NewProc("CoCreateInstance")
	procCoUninitialize             = modOle32.NewProc("CoUninitialize")
)

var (
	CLSID_VirtualDesktopManager = newGUID("{aa509086-5ca9-4c25-8f95-589d3c07b48a}")
	IID_IVirtualDesktopManager  = newGUID("{a5cd92ff-29be-454c-8d04-d82879fb3f1b}")
)

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

type Options struct {
	Title              string `json:"title,omitempty"`
	Prog               string `json:"prog,omitempty"`
	Class              string `json:"class,omitempty"`
	Regex              bool   `json:"regex,omitempty"`
	Desktop            string `json:"desktop,omitempty"`
	Tmux               string `json:"tmux,omitempty"`
	RegisterProtocol   bool   `json:"-"`
	UnregisterProtocol bool   `json:"-"`
}

var (
	validDistroRegex = regexp.MustCompile(`^[a-zA-Z0-9_\-]+$`)
	validClientRegex = regexp.MustCompile(`^/dev/pts/[0-9]+$`)
	validTargetRegex = regexp.MustCompile(`^[a-zA-Z0-9_\-\.:%@]+$`)
)

func main() {
	// 子プロセスかどうかをチェック
	if envData := os.Getenv(childEnvVar); envData != "" {
		runChild(envData)
		return
	}

	if len(os.Args) < 2 {
		printUsage()
		os.Exit(1)
	}

	opts, err := parseOptions(os.Args[1:])
	if err != nil {
		fmt.Fprintf(os.Stderr, "parse options failed: %v\n", err)
		os.Exit(1)
	}

	if opts.RegisterProtocol {
		if err := registerProtocol(); err != nil {
			fmt.Fprintf(os.Stderr, "failed to register protocol: %v\n", err)
			os.Exit(1)
		}
		return
	}
	if opts.UnregisterProtocol {
		if err := unregisterProtocol(); err != nil {
			fmt.Fprintf(os.Stderr, "failed to unregister protocol: %v\n", err)
			os.Exit(1)
		}
		return
	}

	// 親プロセス: 自分自身を子プロセスとして再実行
	if err := relaunchAsChild(opts); err != nil {
		fmt.Fprintf(os.Stderr, "failed to relaunch: %v\n", err)
		os.Exit(1)
	}
}

func runChild(envData string) {
	data, err := base64.StdEncoding.DecodeString(envData)
	if err != nil {
		fmt.Fprintf(os.Stderr, "failed to decode options: %v\n", err)
		os.Exit(1)
	}
	var opts Options
	if err := json.Unmarshal(data, &opts); err != nil {
		fmt.Fprintf(os.Stderr, "failed to unmarshal options: %v\n", err)
		os.Exit(1)
	}

	hr, _, _ := procCoInitialize.Call(0)
	if hr != 0 && hr != 0x00000001 {
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

	runActivate(opts, vdm)
}

func printUsage() {
	// editorconfig-checker-disable
	fmt.Fprintf(os.Stderr, `Usage of %s:
  -title string
        Window title to search
  -prog string
        Program executable name (e.g. wezterm-gui.exe)
  -class string
        Window class name (e.g. window, Alacritty)
  -regex
        Match title, prog, and class using regular expressions
  -desktop string
        Virtual desktop mode: prefer-current (default), only-current, any
  -tmux string
        tmux target to switch (e.g. distro=fedora;client=/dev/pts/0;$1:@3.%%7)
  -register-protocol
        Register wsl-toast protocol handler in registry
  -unregister-protocol
        Unregister wsl-toast protocol handler from registry
`, filepath.Base(os.Args[0]))
	// editorconfig-checker-enable
}

func parseOptions(args []string) (Options, error) {
	var opts Options
	opts.Desktop = "prefer-current"

	// 引数が1つでフラグでない場合
	if len(args) == 1 && !strings.HasPrefix(args[0], "-") {
		if strings.HasPrefix(args[0], "wsl-toast:") {
			return parseProtocolURL(args[0])
		}
		opts.Title = args[0]
		return opts, nil
	}

	fs := flag.NewFlagSet("win-activate-process", flag.ContinueOnError)
	fs.StringVar(&opts.Title, "title", "", "Window title")
	fs.StringVar(&opts.Prog, "prog", "", "Program executable name")
	fs.StringVar(&opts.Class, "class", "", "Window class name")
	fs.BoolVar(&opts.Regex, "regex", false, "Use regex matching")
	fs.StringVar(&opts.Desktop, "desktop", "prefer-current", "Virtual desktop mode: prefer-current, only-current, any")
	fs.StringVar(&opts.Tmux, "tmux", "", "tmux target (e.g. distro=fedora;client=/dev/pts/0;$1:@3.%7)")
	fs.BoolVar(&opts.RegisterProtocol, "register-protocol", false, "Register wsl-toast protocol handler in registry")
	fs.BoolVar(&opts.UnregisterProtocol, "unregister-protocol", false, "Unregister wsl-toast protocol handler from registry")

	if err := fs.Parse(args); err != nil {
		return opts, err
	}
	return opts, nil
}

func parseProtocolURL(rawURL string) (Options, error) {
	var opts Options
	opts.Desktop = "prefer-current"

	u, err := url.Parse(rawURL)
	if err != nil {
		return opts, fmt.Errorf("invalid URL: %w", err)
	}
	if u.Scheme != "wsl-toast" {
		return opts, fmt.Errorf("unsupported scheme: %s", u.Scheme)
	}

	action := u.Host
	if action == "" {
		action = strings.TrimPrefix(u.Path, "/")
	}
	if action != "activate" && action != "focus" {
		return opts, fmt.Errorf("unsupported action: %s", action)
	}

	q := u.Query()
	opts.Title = q.Get("title")
	opts.Prog = q.Get("prog")
	opts.Class = q.Get("class")
	if q.Get("regex") == "true" || q.Get("regex") == "1" {
		opts.Regex = true
	}
	if d := q.Get("desktop"); d != "" {
		opts.Desktop = d
	}

	if tmuxVal := q.Get("tmux"); tmuxVal != "" {
		opts.Tmux = tmuxVal
	} else {
		// 後方互換形式 (focus?distro=...&client=...&session=...&window=...&pane=...)
		distro := q.Get("distro")
		client := q.Get("client")
		session := q.Get("session")
		window := q.Get("window")
		pane := q.Get("pane")

		target := session
		if window != "" {
			target += ":" + window
		}
		if pane != "" {
			target += "." + pane
		}

		var parts []string
		if distro != "" {
			parts = append(parts, "distro="+distro)
		}
		if client != "" {
			parts = append(parts, "client="+client)
		}
		if target != "" {
			parts = append(parts, target)
		}
		opts.Tmux = strings.Join(parts, ";")
	}

	return opts, nil
}

type windowMatcher struct {
	titleRegex *regexp.Regexp
	progRegex  *regexp.Regexp
	classRegex *regexp.Regexp
	titleLower string
	progLower  string
	classLower string
	isRegex    bool
}

func newWindowMatcher(opts Options) (*windowMatcher, error) {
	m := &windowMatcher{isRegex: opts.Regex}
	if opts.Regex {
		if opts.Title != "" {
			re, err := regexp.Compile("(?i)" + opts.Title)
			if err != nil {
				return nil, fmt.Errorf("invalid title regex: %w", err)
			}
			m.titleRegex = re
		}
		if opts.Prog != "" {
			re, err := regexp.Compile("(?i)" + opts.Prog)
			if err != nil {
				return nil, fmt.Errorf("invalid prog regex: %w", err)
			}
			m.progRegex = re
		}
		if opts.Class != "" {
			re, err := regexp.Compile("(?i)" + opts.Class)
			if err != nil {
				return nil, fmt.Errorf("invalid class regex: %w", err)
			}
			m.classRegex = re
		}
	} else {
		m.titleLower = strings.ToLower(opts.Title)
		m.progLower = strings.ToLower(opts.Prog)
		m.classLower = strings.ToLower(opts.Class)
	}
	return m, nil
}

func (m *windowMatcher) match(hwnd uintptr) bool {
	if m.isRegex {
		if m.titleRegex != nil {
			title := getWindowText(hwnd)
			if !m.titleRegex.MatchString(title) {
				return false
			}
		}
		if m.progRegex != nil {
			prog := getProcessName(hwnd)
			if !m.progRegex.MatchString(prog) {
				return false
			}
		}
		if m.classRegex != nil {
			class := getClassName(hwnd)
			if !m.classRegex.MatchString(class) {
				return false
			}
		}
	} else {
		if m.titleLower != "" {
			title := strings.ToLower(getWindowText(hwnd))
			if !strings.Contains(title, m.titleLower) {
				return false
			}
		}
		if m.progLower != "" {
			prog := strings.ToLower(getProcessName(hwnd))
			if !strings.Contains(prog, m.progLower) {
				return false
			}
		}
		if m.classLower != "" {
			class := strings.ToLower(getClassName(hwnd))
			if !strings.Contains(class, m.classLower) {
				return false
			}
		}
	}
	return true
}

func runActivate(opts Options, vdm *IVirtualDesktopManager) {
	// 1. ウィンドウのアクティブ化
	if opts.Title != "" || opts.Prog != "" || opts.Class != "" {
		matcher, err := newWindowMatcher(opts)
		if err != nil {
			fmt.Fprintf(os.Stderr, "matcher error: %v\n", err)
			os.Exit(1)
		}

		hwnd := findWindow(matcher, opts.Desktop, vdm)
		// フォールバック: 指定された条件で見つからず、tmux 指定がある場合は主要なターミナルを探索
		if hwnd == 0 && opts.Tmux != "" {
			for _, fallbackProg := range []string{"WindowsTerminal.exe", "wezterm-gui.exe", "alacritty.exe"} {
				fallbackMatcher, _ := newWindowMatcher(Options{Prog: fallbackProg})
				hwnd = findWindow(fallbackMatcher, opts.Desktop, vdm)
				if hwnd != 0 {
					break
				}
			}
		}

		if hwnd != 0 {
			activateWindow(hwnd)
		} else {
			if opts.Tmux == "" {
				fmt.Fprintf(os.Stderr, "window not found\n")
				os.Exit(1)
			}
		}
	}

	// 2. tmux フォーカス切り替え
	if opts.Tmux != "" {
		executeTmuxFocus(opts.Tmux)
	}
}

func findWindow(matcher *windowMatcher, desktopMode string, vdm *IVirtualDesktopManager) uintptr {
	var currentDesktopHwnd uintptr
	var otherDesktopHwnd uintptr

	cb := syscall.NewCallback(func(hwnd uintptr, _ uintptr) uintptr {
		if !isWindowVisible(hwnd) {
			return 1 // continue
		}

		if !matcher.match(hwnd) {
			return 1 // continue
		}

		if desktopMode == "any" {
			currentDesktopHwnd = hwnd
			return 0 // stop
		}

		if vdm != nil {
			var isOnCurrent int32
			hr, _, _ := syscall.Syscall(vdm.LpVtbl.IsWindowOnCurrentVirtualDesktop, 3, uintptr(unsafe.Pointer(vdm)), hwnd, uintptr(unsafe.Pointer(&isOnCurrent)))
			if hr == 0 && isOnCurrent != 0 {
				currentDesktopHwnd = hwnd
				return 0 // stop
			}
			if otherDesktopHwnd == 0 {
				otherDesktopHwnd = hwnd
			}
		} else {
			currentDesktopHwnd = hwnd
			return 0
		}
		return 1
	})

	procEnumWindows.Call(cb, 0)

	if currentDesktopHwnd != 0 {
		return currentDesktopHwnd
	}
	if desktopMode == "only-current" {
		return 0
	}
	return otherDesktopHwnd
}

func executeTmuxFocus(tmuxArg string) {
	distro := "fedora"
	client := ""
	target := ""

	for _, part := range strings.Split(tmuxArg, ";") {
		part = strings.TrimSpace(part)
		if strings.HasPrefix(part, "distro=") {
			d := strings.TrimPrefix(part, "distro=")
			if validDistroRegex.MatchString(d) {
				distro = d
			}
		} else if strings.HasPrefix(part, "client=") {
			c := strings.TrimPrefix(part, "client=")
			if validClientRegex.MatchString(c) {
				client = c
			}
		} else if part != "" {
			if validTargetRegex.MatchString(part) {
				target = part
			}
		}
	}

	if target == "" {
		return
	}

	// editorconfig-checker-disable
	const focusScript = `
tmux info &>/dev/null || exit 0

active_client=$(tmux list-clients -F '#{client_activity} #{client_name}' 2>/dev/null | sort -nr | head -n1 | cut -d' ' -f2-)

if [ -n "$TARGET_PARAM" ]; then
  if [ -n "$active_client" ]; then
    tmux switch-client -c "$active_client" -t "$TARGET_PARAM" 2>/dev/null || true
  fi
  if [ -n "$TARGET_CLIENT" ] && [ "$TARGET_CLIENT" != "$active_client" ] && tmux list-clients -F '#{client_name}' 2>/dev/null | grep -Fxq "$TARGET_CLIENT"; then
    tmux switch-client -c "$TARGET_CLIENT" -t "$TARGET_PARAM" 2>/dev/null || true
  fi
fi
`
	// editorconfig-checker-enable

	var args []string
	if distro != "" {
		args = append(args, "-d", distro)
	}
	args = append(args, "--", "bash")

	cmd := exec.Command("wsl.exe", args...)
	cmd.Stdin = strings.NewReader(focusScript)
	cmd.Env = append(os.Environ(),
		"WSLENV=TARGET_CLIENT:TARGET_PARAM",
		"TARGET_CLIENT="+client,
		"TARGET_PARAM="+target,
	)
	cmd.SysProcAttr = &syscall.SysProcAttr{
		HideWindow:    true,
		CreationFlags: 0x08000000, // CREATE_NO_WINDOW
	}
	_ = cmd.Run()
}

func registerProtocol() error {
	exePath, err := getModuleFileName()
	if err != nil {
		return fmt.Errorf("getModuleFileName: %w", err)
	}

	k, _, err := registry.CreateKey(registry.CURRENT_USER, `Software\Classes\wsl-toast`, registry.ALL_ACCESS)
	if err != nil {
		return fmt.Errorf("create wsl-toast key: %w", err)
	}
	defer k.Close()

	if err := k.SetStringValue("", "URL:wsl-toast Protocol"); err != nil {
		return err
	}
	if err := k.SetStringValue("URL Protocol", ""); err != nil {
		return err
	}

	cmdKey, _, err := registry.CreateKey(k, `shell\open\command`, registry.ALL_ACCESS)
	if err != nil {
		return fmt.Errorf("create shell open command key: %w", err)
	}
	defer cmdKey.Close()

	cmdValue := fmt.Sprintf(`"%s" "%%1"`, exePath)
	if err := cmdKey.SetStringValue("", cmdValue); err != nil {
		return err
	}

	return nil
}

func unregisterProtocol() error {
	_ = registry.DeleteKey(registry.CURRENT_USER, `Software\Classes\wsl-toast\shell\open\command`)
	_ = registry.DeleteKey(registry.CURRENT_USER, `Software\Classes\wsl-toast\shell\open`)
	_ = registry.DeleteKey(registry.CURRENT_USER, `Software\Classes\wsl-toast\shell`)
	return registry.DeleteKey(registry.CURRENT_USER, `Software\Classes\wsl-toast`)
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
func relaunchAsChild(opts Options) error {
	// 自分自身の実行ファイルパスを取得
	exePath, err := getModuleFileName()
	if err != nil {
		return fmt.Errorf("GetModuleFileNameW: %w", err)
	}

	// オプションを JSON + Base64 にシリアライズして環境変数に設定（子プロセスに継承される）
	data, err := json.Marshal(opts)
	if err != nil {
		return fmt.Errorf("marshal options: %w", err)
	}
	os.Setenv(childEnvVar, base64.StdEncoding.EncodeToString(data))

	// ShellExecuteEx で起動（引数は環境変数で渡すため指定不要）
	exePathPtr, _ := syscall.UTF16PtrFromString(exePath)

	var sei shellExecuteInfo
	sei.CbSize = uint32(unsafe.Sizeof(sei))
	sei.FMask = seeMaskNocloseprocess
	sei.File = exePathPtr
	sei.Parameters = nil
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

func getWindowText(hwnd uintptr) string {
	length, _, _ := procGetWindowTextLengthW.Call(hwnd)
	if length == 0 {
		return ""
	}

	buf := make([]uint16, length+1)
	procGetWindowTextW.Call(hwnd, uintptr(unsafe.Pointer(&buf[0])), uintptr(len(buf)))
	return syscall.UTF16ToString(buf)
}

func getClassName(hwnd uintptr) string {
	buf := make([]uint16, 256)
	ret, _, _ := procGetClassNameW.Call(hwnd, uintptr(unsafe.Pointer(&buf[0])), uintptr(len(buf)))
	if ret == 0 {
		return ""
	}
	return syscall.UTF16ToString(buf)
}

func getProcessName(hwnd uintptr) string {
	var pid uint32
	procGetWindowThreadProcessId.Call(hwnd, uintptr(unsafe.Pointer(&pid)))
	if pid == 0 {
		return ""
	}
	hProc, _, _ := procOpenProcess.Call(PROCESS_QUERY_LIMITED_INFORMATION, 0, uintptr(pid))
	if hProc == 0 {
		return ""
	}
	defer windows.CloseHandle(windows.Handle(hProc))

	buf := make([]uint16, windows.MAX_PATH)
	size := uint32(len(buf))
	ret, _, _ := procQueryFullProcessImageNameW.Call(hProc, 0, uintptr(unsafe.Pointer(&buf[0])), uintptr(unsafe.Pointer(&size)))
	if ret == 0 {
		return ""
	}
	fullPath := syscall.UTF16ToString(buf)
	return filepath.Base(fullPath)
}

func isWindowVisible(hwnd uintptr) bool {
	ret, _, _ := procIsWindowVisible.Call(hwnd)
	return ret != 0
}

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
