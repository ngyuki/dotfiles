winapps := ${USERPROFILE}/AppData/Local/Microsoft/WindowsApps

.PHONY: all
all: win-activate-process.exe
	for fn in setup/[0-9]*.sh; do "$$fn"; done

.PHONY: winhome
winhome:
	unison -auto "${USERPROFILE}/dotfiles/winhome/" "${PWD}/winhome/"

packages/go-win-activate-process/win-activate-process.exe:
	make -C packages/go-win-activate-process build

${winapps}/win-activate-process.exe: packages/go-win-activate-process/win-activate-process.exe
	cp $< $@

.PHONY: win-activate-process.exe
win-activate-process.exe: ${winapps}/win-activate-process.exe
