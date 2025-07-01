package main

import (
	"fmt"
	"os"
	"path/filepath"
	"syscall"
	"unsafe"

	"golang.org/x/sys/windows"
)

var (
	modUser32                    = windows.NewLazySystemDLL("user32.dll")
	procEnumWindows              = modUser32.NewProc("EnumWindows")
	procIsWindowVisible          = modUser32.NewProc("IsWindowVisible")
	procGetWindowThreadProcessId = modUser32.NewProc("GetWindowThreadProcessId")
	procSetForegroundWindow      = modUser32.NewProc("SetForegroundWindow")
	procGetWindowPlacement       = modUser32.NewProc("GetWindowPlacement")
	procShowWindow               = modUser32.NewProc("ShowWindow")
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
	swShowMaximised = 3
)

func main() {
	if len(os.Args) != 2 {
		fmt.Fprintf(os.Stderr, "usage: %s <ExecutableName>\n", filepath.Base(os.Args[0]))
		os.Exit(1)
	}

	target := filepath.Base(os.Args[1])

	hwnd := findWindowByProcess(target)
	if hwnd == 0 {
		fmt.Fprintln(os.Stderr, "activatecode: window for", target, "not found")
		os.Exit(1)
	}

	// remember current state (maximised / normal)
	var wp windowPlacement
	wp.Length = uint32(unsafe.Sizeof(wp))
	procGetWindowPlacement.Call(hwnd, uintptr(unsafe.Pointer(&wp)))

	// bring to foreground
	procSetForegroundWindow.Call(hwnd)

	// restore maximised if it was maximised already
	if wp.ShowCmd == swShowMaximised {
		procShowWindow.Call(hwnd, swShowMaximised)
	}
}

func findWindowByProcess(exeName string) uintptr {
	var found uintptr

	cb := syscall.NewCallback(func(hwnd uintptr, _ uintptr) uintptr {
		// Only consider visible, top‑level windows.
		visible, _, _ := procIsWindowVisible.Call(hwnd)
		if visible == 0 {
			return 1 // continue enumeration
		}

		var pid uint32
		procGetWindowThreadProcessId.Call(hwnd, uintptr(unsafe.Pointer(&pid)))
		if pid == 0 {
			return 1
		}

		hProc, err := windows.OpenProcess(windows.PROCESS_QUERY_LIMITED_INFORMATION, false, pid)
		if err != nil {
			return 1
		}
		defer windows.CloseHandle(hProc)

		buf := make([]uint16, 260)
		n := uint32(len(buf))
		err = windows.QueryFullProcessImageName(hProc, 0, &buf[0], &n)
		if err != nil {
			return 1
		}
		name := filepath.Base(windows.UTF16ToString(buf[:n]))
		if name == exeName {
			found = hwnd
			return 0 // stop enumeration
		}
		return 1 // continue
	})

	procEnumWindows.Call(cb, 0)
	return found
}
