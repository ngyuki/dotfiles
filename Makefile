USERPROFILE := $(shell cmd.exe /c 'echo %USERPROFILE%' 2>/dev/null | tr -d '\r')
USERPROFILE := $(shell wslpath -u -- "${USERPROFILE}")

.PHONY: all
all: ~/dotfiles dotsync winhome win-activate-process.exe ansible

.PHONY: ~/dotfiles
~/dotfiles:
	ln -sfnr . ~/dotfiles

.PHONY: dotsync
dotsync:
	setup/dotsync.sh home/ ~/ -auto

.PHONY: ansible
ansible:
	ansible-playbook -i localhost, ansible/playbook.yml -D

.PHONY: winhome
winhome:
	setup/dotsync.sh winhome/ "${USERPROFILE}" -auto

${USERPROFILE}/bin/win-activate-process.exe:
	make -C packages/go-win-activate-process install

.PHONY: win-activate-process.exe
win-activate-process.exe: ${USERPROFILE}/bin/win-activate-process.exe
