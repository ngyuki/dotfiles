.PHONY: all
all: win-activate-process.exe
	for fn in setup/[0-9]*.sh; do "$$fn"; done

.PHONY: winhome
winhome:
	./setup/05-winhome.sh -auto

${USERPROFILE}/bin/win-activate-process.exe:
	make -C packages/go-win-activate-process install

.PHONY: win-activate-process.exe
win-activate-process.exe: ${USERPROFILE}/bin/win-activate-process.exe
