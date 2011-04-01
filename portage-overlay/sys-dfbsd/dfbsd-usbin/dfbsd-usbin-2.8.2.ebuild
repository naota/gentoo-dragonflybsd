EAPI=3
EDFLY_DIR=usr.sbin

inherit dragonfly

DESCRIPTION="DragonFly /usr/sbin tools"
SLOT="0"
KEYWORDS="~x86-dfbsd"

RDEPEND="=sys-dfbsd/dfbsd-lib-${PV}*[usb?,bluetooth?,netware?]
	=sys-dfbsd/dfbsd-libexec-${PV}*
	acpi? ( sys-power/iasl )
	ssl? ( dev-libs/openssl )
	tcpd? ( sys-apps/tcp-wrappers )
	dev-libs/libelf
	dev-libs/libedit
	net-libs/libpcap"
DEPEND="${RDEPEND}
	dev-libs/libevent
	=sys-dfbsd/dfbsd-mk-defs-${PV}*
	sys-apps/texinfo
	sys-devel/flex"

PROVIDE="virtual/logger"

IUSE="acpi atm ipv6 isdn nis ssl tcpd"

PATCHES=( "${FILESDIR}"/${PN}-2.6.3-nowrap.patch 
	"${FILESDIR}"/${PN}-2.6.3-adduser.patch 
	"${FILESDIR}"/${PN}-2.6.3-tzsetup.patch )
REMOVE_SUBDIRS="
	named named-checkzone named-checkconf rndc rndc-confgen
	dnssec-keygen dnssec-signzone
	tcpdchk tcpdmatch
	sendmail praliases editmap mailstats makemap
	sysinstall cron mailwrapper ntp bsnmpd
	tcpdump ndp inetd
	wpa/wpa_supplicant wpa/hostapd wpa/hostapd_cli
	wpa/wpa_cli wpa/wpa_passphrase
	zic amd
	pkg_install authpf mailwrapper makewhatis 802_11"


pkg_setup() {
	use acpi || REMOVE_SUBDIRS="${REMOVE_SUBDIRS} acpi"	
	if ! use atm; then 
		REMOVE_SUBDIRS="${REMOVE_SUBDIRS} atm"	
		mymakeopts="${mymakeopts} NOATM= "
	fi
	use ipv6 || mymakeopts="${mymakeopts} NOINET6= NO_INET6= "
	use isdn || mymakeopts="${mymakeopts} NOI4B= NO_I4B= "
	use nis || mymakeopts="${mymakeopts} NO_NIS= "	
	use ssl || mymakeopts="${mymakeopts} NO_OPENSSL= "	
	use tcpd || mymakeopts="${mymakeopts} NO_WRAP= "

	mymakeopts="${mymakeopts} NO_BIND= NO_LPR= NO_SENDMAIL= "
}

src_prepare() {
	ln -s "/usr/src/sys-${PV}" "${WORKDIR}/${P}/sys"
	ln -s "/usr/include" "${WORKDIR}/${P}/include"
	sed -e "s: mtree.5::g" -i "${S}"/mtree/Makefile
}

src_install() {
	dodir /usr/share/doc
	dodir /sbin
	dodir /usr/libexec
	dodir /usr/bin

	mkinstall NOFSCHG=yes DOCDIR=/usr/share/doc/${PF} || die "Install failed"

	for util in nfs rpc.statd rpc.lockd; do
		newinitd "${FILESDIR}/"${util}.initd ${util} || die
		if [[ -e "${FILESDIR}"/${util}.confd ]]; then 
			newconfd "${FILESDIR}"/${util}.confd ${util} || die
		fi
	done

	for class in daily monthly weekly; do
		cat - > "${T}/periodic.${class}" <<EOS
#!/bin/sh
/usr/sbin/periodic ${class}
EOS
		exeinto /etc/cron.${class}
		newexe "${T}/periodic.${class}" periodic
	done

	# Install the pw.conf file to let pw use Gentoo's skel location
	insinto /etc
	doins "${FILESDIR}/pw.conf" || die

	cd "${WORKDIR}/${P}/etc"
	doins apmd.conf syslog.conf newsyslog.conf nscd.conf || die

	insinto /etc/ppp
	doins ppp/ppp.conf || die

	if use isdn; then
		insinto /etc/isdn
		doins isdn/* || die
		rm -f "${D}"/etc/isdn/Makefile
	fi

	# Install the periodic stuff (needs probably to be ported in a more
	# gentooish way)
	cd "${WORKDIR}/${P}/etc/periodic"

	doperiodic daily daily/*.accounting
	doperiodic monthly monthly/*.accounting
}

pkg_postinst() {
	# We need to run pwd_mkdb if key files are not present
	# If they are, then there is no need to run pwd_mkdb
	if [[ ! -e "${ROOT}etc/passwd" || ! -e "${ROOT}etc/pwd.db" || ! -e "${ROOT}etc/spwd.db" ]] ; then
		if [[ -e "${ROOT}etc/master.passwd" ]] ; then
			einfo "Generating passwd files from ${ROOT}etc/master.passwd"
			"${ROOT}"usr/sbin/pwd_mkdb -p -d "${ROOT}etc" "${ROOT}etc/master.passwd"
		else
			eerror "${ROOT}etc/master.passwd does not exist!"
			eerror "You will no be able to log into your system!"
		fi
	fi

	for logfile in messages security auth.log maillog lpd-errs xferlog cron \
		debug.log slip.log ppp.log; do
		[[ -f "${ROOT}/var/log/${logfile}" ]] || touch "${ROOT}/var/log/${logfile}"
	done
}
