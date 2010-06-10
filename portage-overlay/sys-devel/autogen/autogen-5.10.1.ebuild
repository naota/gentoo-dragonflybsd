# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/autogen/autogen-5.10.1.ebuild,v 1.1 2010/04/21 19:19:48 pva Exp $

EAPI="2"
inherit eutils

DESCRIPTION="Program and text file generation"
HOMEPAGE="http://www.gnu.org/software/autogen/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~x86-fbsd"
IUSE=""

# autogen doesn't build with lower versions of guile on ia64
DEPEND=">=dev-scheme/guile-1.6.6
	dev-libs/libxml2"

pkg_setup() {
	has_version '>=dev-scheme/guile-1.8' || return 0
	if ! built_with_use --missing false dev-scheme/guile deprecated threads ; then
		eerror "You need to build dev-scheme/guile with USE='deprecated threads'"
		die "re-emerge dev-scheme/guile with USE='deprecated threads'"
	fi
}

src_prepare() {
	epatch "${FILESDIR}/autogen-5.10.1-build-hang.patch"
	epatch "${FILESDIR}/autogen-5.10.1-chmod.patch"
}

src_install() {
	emake DESTDIR="${D}" install || die "install failed"
	dodoc AUTHORS ChangeLog NEWS NOTES README THANKS TODO
	rm -f "${D}"/usr/share/autogen/libopts-*.tar.gz
}
