# Compiler config
CC       = gcc
CFLAGS   = -Wall -Wextra -g -O2 -std=c99
GHC      = ghc
GHCFLAGS = -Wall -O2

PREFIX =${HOME}/opt/bin

# Executables
EXE     = word mdo tryless mirror-hg
SCRIPTS = caps2ctl set-random-wallpaper x-set-keyboard ghc-alternative makemake 2translit

.PHONY: all clean install
all : ${EXE}
clean:
	rm -rf *.o ${EXE}
install: all
	mkdir -p ${DESTDIR}/${PREFIX}
	install ${EXE}     ${DESTDIR}/${PREFIX}/
	install ${SCRIPTS} ${DESTDIR}/${PREFIX}/

word: word.c
	${CC} ${CFLAGS} -o $@ $<
mdo: mdo.c
	${CC} ${CFLAGS} -o $@ $<
tryless: tryless.c
	${CC} ${CFLAGS} -o $@ $<
mirror-hg: mirror-hg.hs
	${GHC} ${GHCFLAGS} -o $@ $<
