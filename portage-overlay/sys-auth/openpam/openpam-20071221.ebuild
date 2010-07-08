# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-auth/openpam/openpam-20071221.ebuild,v 1.6 2010/05/02 11:20:56 aballier Exp $

EAPI="2"
inherit multilib autotools

DESCRIPTION="Open source PAM library."
HOMEPAGE="http://www.openpam.org/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~sparc-fbsd ~x86-fbsd ~x86-dfbsd"
IUSE="debug vim-syntax"

RDEPEND="!virtual/pam"
DEPEND="sys-devel/make
	dev-lang/perl"
PDEPEND="sys-auth/pambase
	vim-syntax? ( app-vim/pam-syntax )"

PROVIDE="virtual/pam"

src_prepare() {
	epatch "${FILESDIR}/${P}-gentoo.patch"
	epatch "${FILESDIR}/${PN}-20050201-nbsd.patch"
	epatch "${FILESDIR}/${PN}-20050616-redef.patch"
	epatch "${FILESDIR}/${PN}-20050616-optional.patch"
	epatch "${FILESDIR}/${P}-path.patch"

	sed -i -e 's:-Werror::' "${S}/configure.ac"

	eautoreconf
	elibtoolize
}

src_configure() {
	econf ${myconf} \
		--disable-dependency-tracking \
		--with-modules-dir=/$(get_libdir)/security
}

src_install() {
	emake -j1 DESTDIR="${D}" install || die
	dodoc CREDITS HISTORY RELNOTES README || die

	find "${D}" -name '*.la' -delete || die
}
