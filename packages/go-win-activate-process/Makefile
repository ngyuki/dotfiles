winhome := $(shell cmd.exe /c echo %USERPROFILE% 2>/dev/null)
wslhome := $(shell wslpath -u "${winhome}")
winapps := ${wslhome}/AppData/Local/Microsoft/WindowsApps
target := win-activate-process.exe

build: ${target}

${target}:
	GOOS=windows GOARCH=amd64 CGO_ENABLED=0 go build -ldflags "-s -w -H windowsgui" -o $@ .

install: ${winapps}/${target}

${winapps}/${target}: ${target}
	cp ${target} ${winapps}/${target}

clean:
	rm -fv ${target}

.PHONY: build install clean
