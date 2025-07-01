target := win-activate-process.exe

build: ${target}

${target}:
	GOOS=windows GOARCH=amd64 CGO_ENABLED=0 go build -ldflags "-s -w -H windowsgui" -o $@ .

install: build
	install -m 755 ${target} ~/bin/${target}

clean:
	rm -fv ${target}

.PHONY: build install clean
