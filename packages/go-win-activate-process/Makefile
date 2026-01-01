winhome := $(shell cmd.exe /c echo %USERPROFILE% 2>/dev/null)
wslhome := $(shell wslpath -u "${winhome}")
target  := win-activate-process

build: ${target}.exe

${target}.exe: main.go
	GOOS=windows GOARCH=amd64 CGO_ENABLED=0 go build -ldflags "-s -w -H windowsgui" -o $@ .

install: ${wslhome}/bin/${target}.exe ${HOME}/bin/${target}

${wslhome}/bin/${target}.exe: ${target}.exe
	install -m755 -D -s $< $@

${HOME}/bin/${target}: ${target}.sh
	install -m755 -D $< $@

clean:
	rm -fv ${target}

.PHONY: build install clean
