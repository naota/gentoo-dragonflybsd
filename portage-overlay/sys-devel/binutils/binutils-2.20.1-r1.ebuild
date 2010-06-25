# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/binutils/binutils-2.20.1-r1.ebuild,v 1.1 2010/05/09 08:32:47 vapier Exp $

PATCHVER="1.1"
ELF2FLT_VER=""
inherit toolchain-binutils

KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~sparc-fbsd ~x86-fbsd ~x86-dfbsd"

src_unpack() {
	toolchain-binutils_src_unpack
	epatch "${FILESDIR}"/${P}-dfbsd-ld.patch
}

