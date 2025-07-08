target := wsl-toast

.PHONY: build
build: ${target}

${target}: main.go
	go build -o ${target} main.go

.PHONY: install
install: build
	install -m 755 ${target} ~/bin/${target}

.PHONY: clean
clean:
	rm -fv ${target}

.PHONY: install-systemd
install-systemd:
	mkdir -pv ~/.config/systemd/user/
	cp wsl-toast.service ~/.config/systemd/user/
	systemctl --user daemon-reload
	systemctl --user enable --now wsl-toast.service
	systemctl --user status wsl-toast.service
