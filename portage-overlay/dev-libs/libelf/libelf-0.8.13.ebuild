# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libelf/libelf-0.8.13.ebuild,v 1.1 2010/04/24 15:07:45 ssuominen Exp $

EAPI=2
inherit eutils multilib

DESCRIPTION="A ELF object file access library"
HOMEPAGE="http://www.mr511.de/software/"
SRC_URI="http://www.mr511.de/software/${P}.tar.gz"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~hppa ~ppc ~sparc ~x86 ~sparc-fbsd ~x86-fbsd ~x86-dfbsd"
IUSE="debug nls elibc_FreeBSD"

RDEPEND="!dev-libs/elfutils"
DEPEND="${RDEPEND}
	nls? ( sys-devel/gettext )"

src_prepare() {
	if use elibc_FreeBSD || use elibc_DragonFlyBSD; then
		# Stop libelf from stamping on the system nlist.h
		sed -i \
			-e 's:nlist.h::g' \
			lib/Makefile.in || die

		# Enable shared libs
		sed -i -e \
			's:\*-linux\*\|\*-gnu\*:\*-linux\*\|\*-gnu\*\|\*-freebsd\*\|\*-dragonfly*:' \
			configure || die
	fi

	sed -i \
		-e 's:$(LINK_SHLIB) -o:$(LINK_SHLIB) $(LDFLAGS) -o:' \
		lib/Makefile.in || die
}

src_configure() {
	econf \
		$(use_enable nls) \
		--enable-shared \
		$(use_enable debug)
}

src_install() {
	emake -j1 \
		prefix="${D}usr" \
		libdir="${D}usr/$(get_libdir)" \
		install \
		install-compat || die
	dodoc ChangeLog README
}
