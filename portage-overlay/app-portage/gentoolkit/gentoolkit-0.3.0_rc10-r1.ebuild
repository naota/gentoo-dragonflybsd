# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-portage/gentoolkit/gentoolkit-0.3.0_rc10-r1.ebuild,v 1.2 2010/04/27 10:15:18 aballier Exp $

EAPI="2"
SUPPORT_PYTHON_ABIS="1"
DISTUTILS_DISABLE_VERSIONING_OF_PYTHON_SCRIPTS="1"
RESTRICT_PYTHON_ABIS="2.[45]"

inherit distutils python eutils

DESCRIPTION="Collection of administration scripts for Gentoo"
HOMEPAGE="http://www.gentoo.org/proj/en/portage/tools/index.xml"
SRC_URI="mirror://gentoo/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
IUSE=""

# Drop ~sparc-fbsd ~x86-fbsd due to app-misc/realpath dependency
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~sparc-fbsd ~x86-fbsd"

DEPEND="sys-apps/portage
	>=dev-lang/python-2.6[xml]
	!!>=dev-lang/python-2.6[-xml]"
RDEPEND="${DEPEND}
	|| ( app-misc/realpath sys-freebsd/freebsd-bin )
	sys-apps/gawk
	sys-apps/grep"

src_prepare() {
	epatch "${FILESDIR}/eclean.313901.patch"
}

distutils_src_compile_pre_hook() {
	echo VERSION="${PVR}" "$(PYTHON)" setup.py set_version
	VERSION="${PVR}" "$(PYTHON)" setup.py set_version
}

src_install() {
	python_convert_shebangs -r "" build-*/scripts-*
	distutils_src_install

	# Create cache directory for revdep-rebuild
	dodir /var/cache/revdep-rebuild
	keepdir /var/cache/revdep-rebuild
	fowners root:root /var/cache/revdep-rebuild
	fperms 0700 /var/cache/revdep-rebuild

	# Can distutils handle this?
	dosym eclean /usr/bin/eclean-dist
	dosym eclean /usr/bin/eclean-pkg
}

pkg_postinst() {
	distutils_pkg_postinst

	# Make sure that our ownership and permissions stuck
	chown root:root "${ROOT}/var/cache/revdep-rebuild"
	chmod 0700 "${ROOT}/var/cache/revdep-rebuild"

	einfo
	einfo "For further information on gentoolkit, please read the gentoolkit"
	einfo "guide: http://www.gentoo.org/doc/en/gentoolkit.xml"
	einfo
	einfo "Another alternative to equery is app-portage/portage-utils"
}
