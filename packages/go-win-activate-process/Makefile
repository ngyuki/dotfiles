winhome := $(shell cmd.exe /c echo %USERPROFILE% 2>/dev/null)
wslhome := $(shell wslpath -u "${winhome}")
target  := win-activate-process

build: ${target}.exe

${target}.exe: main.go
	GOOS=windows GOARCH=amd64 CGO_ENABLED=0 go build -ldflags "-s -w -H windowsgui" -o $@ .

install: ${wslhome}/bin/${target}.exe

${wslhome}/bin/${target}.exe: ${target}.exe
	install -m755 -D -s $< $@

clean:
	rm -fv ${target}

.PHONY: build install clean
