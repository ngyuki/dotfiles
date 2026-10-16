.PHONY: all
all: ~/dotfiles dotsync win-activate-process.exe setup-scripts

.PHONY: ~/dotfiles
~/dotfiles:
	ln -sfnr . ~/dotfiles

.PHONY: dotsync
dotsync:
	setup/dotsync.sh home/ ~/ -auto

.PHONY: setup-scripts
setup-scripts:
	for fn in setup/[0-9]*.sh; do "$$fn"; done

.PHONY: ansible
ansible:
	ansible-playbook -i localhost, ansible/playbook.yml -D

.PHONY: winhome
winhome:
	./setup/05-winhome.sh -auto

${USERPROFILE}/bin/win-activate-process.exe:
	make -C packages/go-win-activate-process install

.PHONY: win-activate-process.exe
win-activate-process.exe: ${USERPROFILE}/bin/win-activate-process.exe
