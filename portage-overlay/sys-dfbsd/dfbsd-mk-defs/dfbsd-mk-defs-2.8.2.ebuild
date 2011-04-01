# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3
EDFLY_DIR="share/mk"

inherit dragonfly

DESCRIPTION="Makefile definitions used for building and installing libraries and system files"

SLOT="0"
KEYWORDS="~x86-dfbsd"

RESTRICT="strip"


src_unpack() {
	git_src_unpack
	cd "${WORKDIR}"/${PN}-2.6.3/share/mk
	epatch "${FILESDIR}"/${PN}-2.6.3-gentoo.patch
}

src_configure() { :; }
src_compile() { :; }

src_install() {
	cd "${WORKDIR}"/${PN}-2.6.3/share/mk
	if [[ ${CHOST} != *-dragonfly* ]]; then
		insinto /usr/share/mk/dragonfly
	else
		insinto /usr/share/mk
	fi
	doins *.mk
}
