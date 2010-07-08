# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3
EDFLY_DIR="libexec"

inherit dragonfly

DESCRIPTION="DragonFly libexec things"

SLOT="0"
KEYWORDS="~x86-dfbsd"
IUSE="ipv6 openssl pam xinetd"

RDEPEND="=sys-dfbsd/dfbsd-lib-${PV}*
	pam? ( virtual/pam )"
DEPEND="${RDEPEND}
	=sys-dfbsd/dfbsd-mk-defs-${PV}*
	=sys-dfbsd/dfbsd-sources-${PV}*"

PATCHES=( "${FILESDIR}"/${P}-rtld.patch )
REMOVE_SUBDIRS="smrsh mail.local tcpd telnetd rshd rlogind ftpd"

pkg_setup() {
	use ipv6 || mymakeopts="${mymakeopts} NO_INET6= "
	use pam || mymakeopts="${mymakeopts} NO_PAM= "
	use openssl || mymakeopts="${mymakeopts} NO_OPENSSL= "
}

src_prepare() {
	ln -s /usr/include "${WORKDIR}/${P}/include"
}

src_compile() {
	cd "${WORKDIR}"/${P}/lib/libc_rtld
	dragonfly_src_compile
	cd "${S}"
	dragonfly_src_compile
}

src_install() {
	NOFSCHG=yes dragonfly_src_install

	insinto /etc
	doins "${WORKDIR}/${P}/etc/gettytab"
	newinitd "${FILESDIR}/bootpd.initd" bootpd
	newconfd "${FILESDIR}/bootpd.confd" bootpd

	if use xinetd; then
		for rpcd in rstatd rusersd walld rquotad sprayd; do
			insinto /etc/xinetd.d
			newins "${FILESDIR}/${rpcd}.xinetd" ${rpcd}
		done
	fi
}
