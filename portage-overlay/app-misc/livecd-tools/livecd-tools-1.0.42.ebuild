# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-misc/livecd-tools/livecd-tools-1.0.42.ebuild,v 1.1 2009/06/29 16:51:24 agaffney Exp $

inherit eutils

DESCRIPTION="Gentoo LiveCD tools for autoconfiguration of hardware"
HOMEPAGE="http://wolf31o2.org/projects/livecd-tools"
SRC_URI="mirror://gentoo/${P}.tar.bz2
	http://wolf31o2.org/sources/${PN}/${P}.tar.bz2"

SLOT="0"
LICENSE="GPL-2"
#KEYWORDS="~alpha ~amd64 ~hppa ~ia64 ~mips ~ppc ~ppc64 ~sparc ~x86"
KEYWORDS="alpha amd64 hppa ia64 ~mips ppc ppc64 sparc x86"
IUSE="opengl X"

OPENGL_DEPEND="virtual/opengl
	x11-misc/mkxf86config
	app-admin/eselect-opengl"

RDEPEND="dev-util/dialog
	sys-apps/pciutils
	sys-apps/gawk
	sys-apps/sed
	alpha? ( opengl? ( ${OPENGL_DEPEND} )
		X? ( >=x11-misc/mkxf86config-0.9.7 ) )
	amd64? ( opengl? ( ${OPENGL_DEPEND} )
		X? ( >=x11-misc/mkxf86config-0.9.2 ) )
	x86? ( opengl? ( ${OPENGL_DEPEND} )
		X? ( x11-misc/mkxf86config ) )
	ppc? ( opengl? ( ${OPENGL_DEPEND} )
		X? ( >=x11-misc/mkxf86config-0.9.7 ) )"

pkg_setup() {
		ewarn "This package is designed for use on the LiveCD only and will do"
		ewarn "unspeakably horrible and unexpected things on a normal system."
		ewarn "YOU HAVE BEEN WARNED!!!"
}

src_install() {
	doinitd autoconfig
	newinitd spind.init spind
	if use x86 || use amd64 || use ppc
	then
		if use opengl
		then
			dosbin x-setup openglify
			newinitd x-setup.init x-setup
		fi
	fi
	dosbin net-setup spind
	into /
	dobin bashlogin
	dosbin livecd-functions.sh
}
