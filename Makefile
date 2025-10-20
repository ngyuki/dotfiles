
.PHONY: all
all:
	for fn in setup/[0-9]*.sh; do "$$fn"; done

.PHONY: winhome
winhome:
	unison -auto "${USERPROFILE}/dotfiles/winhome/" "${PWD}/winhome/"
