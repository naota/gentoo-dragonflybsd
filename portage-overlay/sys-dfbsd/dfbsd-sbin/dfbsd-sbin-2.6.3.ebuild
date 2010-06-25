# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3
EGIT_REPO_URI="git://git.dragonflybsd.org/dragonfly.git"
EGIT_COMMIT="v2.6.3"
EGIT_PROJECT="dragonflybsd"

inherit git bsdmk freebsd

DESCRIPTION="DragonFly sbin utils"
HOMEPAGE="http://www.dragonflybsd.org/"

LICENSE=""
SLOT="0"
KEYWORDS="~x86-dfbsd"
IUSE="ipfilter pf"

RDEPEND="=sys-dfbsd/dfbsd-lib-${PV}*
	dev-libs/libedit
	sys-libs/readline
	sys-process/vixie-cron"
DEPEND="=sys-dfbsd/dfbsd-mk-defs-${PV}*"

PROVIDE="virtual/dev-manager"


REMOVE_SUBDIRS="dhclient rcorder newbtconf rcrun"

src_unpack() {
	git_src_unpack
	cd "${S}"
	epatch "${FILESDIR}"/${P}-zlib.patch
	epatch "${FILESDIR}"/${P}-ldconfig.patch
	S="${WORKDIR}/${P}/sbin"
	cd ${S}
	dummy_mk ${REMOVE_SUBDIRS}
	freebsd_rename_libraries
	sed -i.bak -e 's/-lkiconv/-lkiconv -liconv/' \
		mount_cd9660/Makefile mount_msdos/Makefile mount_ntfs/Makefile
}

src_install() {
	NOFSCHG=yes freebsd_src_install
	keepdir /var/log
	# Needed by ldconfig:
	keepdir /var/run

	# Maybe ship our own sysctl.conf so things like radvd work out of the box.
	# New wireless config method requires regdomain.xml in /etc
	cd "${WORKDIR}/${P}/etc/"
	insinto /etc
	doins sysctl.conf || die

	# initd script for idmapd
	newinitd "${FILESDIR}/idmapd.initd" idmapd

	# Install a crontab for adjkerntz
	insinto /etc/cron.d
	newins "${FILESDIR}/adjkerntz-crontab" adjkerntz

	# Install the periodic stuff (needs probably to be ported in a more
	# gentooish way)
	cd "${WORKDIR}/${P}/etc/periodic"

	doperiodic security \
		security/*.ipfwlimit \
		security/*.ipfwdenied || die

	use ipfilter && { doperiodic security \
		security/*.ipfdenied || die ; }

	use pf && { doperiodic security \
		security/*.pfdenied || die ; }
}
