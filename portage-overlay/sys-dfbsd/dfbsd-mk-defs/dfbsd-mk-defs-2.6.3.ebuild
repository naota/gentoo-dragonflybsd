# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3
EGIT_REPO_URI="git://git.dragonflybsd.org/dragonfly.git"
EGIT_COMMIT="v2.6.3"
EGIT_PROJECT="dragonflybsd"

inherit git

DESCRIPTION="Makefile definitions used for building and installing libraries and system files"
HOMEPAGE="http://www.dragonflybsd.org/"

LICENSE=""
SLOT="0"
KEYWORDS="~x86-dfbsd"
IUSE=""

RESTRICT="strip"

src_configure() { :; }
src_compile() { :; }

src_install() {
	cd "${WORKDIR}"/${P}/share/mk
	if [[ ${CHOST} != *-dragonfly* ]]; then
		insinto /usr/share/mk/dragonfly
	else
		insinto /usr/share/mk
	fi
	doins *.mk *.awk
}
