# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3
EDFLY_DIR="sbin"

inherit dragonfly flag-o-matic

DESCRIPTION="DragonFly sbin utils"

SLOT="0"
KEYWORDS="~x86-dfbsd"
IUSE="atm ipfilter ipv6"

RDEPEND="=sys-dfbsd/dfbsd-lib-${PV}*
	dev-libs/libedit
	sys-libs/readline
	sys-devel/flex
	sys-process/vixie-cron"
DEPEND="=sys-dfbsd/dfbsd-mk-defs-${PV}*"

PROVIDE="virtual/dev-manager"


REMOVE_SUBDIRS="dhclient rcorder newbtconf rcrun"
PATCHES=( 
	"${FILESDIR}"/${P}-zlib.patch
	"${FILESDIR}"/${P}-ldconfig.patch
	"${FILESDIR}"/${P}-noshare.patch
	)

pkg_setup() {
	use atm || REMOVE_SUBDIRS="${REMOVE_SUBDIRS} atm"
	use ipfilter || mymakeopts="${mymakeopts} NO_IPFILTER= "
	use ipv6 || mymakeopts="${mymakeopts} NO_INET6= "

	append-flags $(test-flags -static-libgcc)
}

src_unpack() {
	dragonfly_src_unpack

	sed -i.bak -e 's/-lkiconv/-lkiconv -liconv/' \
		mount_cd9660/Makefile mount_msdos/Makefile mount_ntfs/Makefile
}

src_install() {
	NOFSCHG=yes dragonfly_src_install
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
}
