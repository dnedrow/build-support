#!/bin/bash

CONFIGURE="./autogen.sh"
#CONFIGURE="./configure"
#CONFOPT="--disable-xquartz --disable-launchd --enable-kdrive --disable-xsdl --enable-xnest --enable-xvfb"
#CONFOPT="--disable-glx"

#MESA="$(pwd)/../Mesa-6.5.2"
#MESA="$(pwd)/../Mesa-7.0.4"
MESA="$(pwd)/mesa"

# Parallel Make.  Change $MAKE if you don't have gmake installed
MAKE="gnumake"
MAKE_OPTS="-j2"
 
. ~/src/strip.sh

export ACLOCAL="aclocal -I /usr/X11/share/aclocal"

die() {
	echo "${@}" >&2
	exit 1
}

docomp() {
	${CONFIGURE} --prefix=/usr/X11 --with-mesa-source="${MESA}" ${CONFOPT} --disable-dependency-tracking --enable-maintainer-mode --enable-record || die "Could not configure xserver"
	${MAKE} clean || die "Unable to make clean"
	${MAKE} ${MAKE_OPTS} || die "Could not make xserver"
}

doinst() {
	${MAKE} install DESTDIR="$(pwd)/../dist" || die "Could not install xserver"
}

dosign() {
	/opt/local/bin/gmd5sum $1 > $1.md5sum
	/opt/local/bin/gsha1sum $1 > $1.sha1sum
	/opt/local/bin/gpg2 -b $1
}

dodist() {
	${MAKE} dist
	cp hw/xquartz/mach-startup/X11.bin X11.bin-$1
	cp hw/xquartz/mach-startup/Xquartz Xquartz-$1
	bzip2 X11.bin-$1
	bzip2 Xquartz-$1
	dosign X11.bin-$1.bz2 
	dosign Xquartz-$1.bz2 
	dosign xorg-server-$1.tar.bz2
}

docomp
#doinst
[[ -n $1 ]] && dodist $1
