# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-portage/mirrorselect/mirrorselect-2.1.0-r2.ebuild,v 1.1 2010/08/01 20:12:24 idl0r Exp $

EAPI="2"
SUPPORT_PYTHON_ABIS="1"

inherit eutils python

DESCRIPTION="Tool to help select distfiles mirrors for Gentoo"
HOMEPAGE="http://www.gentoo.org/"
SRC_URI="mirror://gentoo/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~x86-fbsd"
IUSE=""

RDEPEND="dev-lang/python[xml]
	dev-util/dialog
	net-analyzer/netselect"

RESTRICT_PYTHON_ABIS="3*"

src_prepare() {
	# bug 312753
	epatch "${FILESDIR}/0001-Fix-rsync-mirror-selectection.patch"
	# bug 330611
	epatch "${FILESDIR}/0002-Check-for-a-valid-mirrorselect-test-file.patch"
}

src_install() {
	newsbin main.py ${PN} || die

	installation() {
		insinto $(python_get_sitedir)
		doins -r ${PN}/
	}
	python_execute_function installation

	doman ${PN}.8 || die
}

pkg_postinst() {
	python_mod_optimize ${PN}
}

pkg_postrm() {
	python_mod_cleanup ${PN}
}
