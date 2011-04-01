EAPI=3
EDFLY_DIR=usr.bin

inherit dragonfly pam

DESCRIPTION="DragonFly's base system source for /usr/bin"
SLOT="0"
KEYWORDS="~x86-dfbsd"
IUSE="nis ssl"

RDEPEND="=sys-dfbsd/dfbsd-lib-${PV}*
	ssl? ( dev-libs/openssl )
	virtual/pam
	sys-libs/zlib"
DEPEND="${RDEPEND}
	sys-devel/flex
	=sys-dfbsd/dfbsd-mk-defs-${PV}*"
RDEPEND="${RDEPEND}
	>=sys-auth/pambase-20080219.1
	sys-process/cronbase"

PATCHES=( "${FILESDIR}"/${PN}-2.6.3-bsdcmp.patch
	"${FILESDIR}"/${PN}-2.6.3-fixmakefiles.patch
	"${FILESDIR}"/${PN}-2.6.3-kdump-ioctl.patch
	"${FILESDIR}"/${PN}-2.6.3-xinstall.patch 
	"${FILESDIR}"/${PN}-2.6.3-doscmd.patch 
	"${FILESDIR}"/${PN}-2.6.3-Makefile.patch 
	"${FILESDIR}"/${PN}-2.6.3-noshare.patch )
REMOVE_SUBDIRS="bzip2 bzip2recover tar cpio
	gzip gprof
	tput tset
	less lessecho lesskey
	drill hesinfo host iconv
	rsh rlogin rusers rwho ruptime
	compile_et lex vi smbutil file vacation ftp telnet
	c99 c89 soelim bc dc
	whois tftp btpin objformat"

pkg_setup() {
	use nis || mymakeopts="${mymakeopts} NO_NIS= "
	use ssl || mymakeopts="${mymakeopts} NO_OPENSSL= "

	mymakeopts="${mymakeopts} NO_SENDMAIL= NO_BIND= "
}

pkg_preinst() {
	if [[ -L ${ROOT}/usr/bin/yacc ]] ; then
		rm -f "${ROOT}"/usr/bin/yacc
	fi
}

src_prepare() {
	mv "${S}"/cmp/cmp.1 "${S}"/cmp/bsdcmp.1 || die
	sed -i -e 's:"manpath -q":"manpath":' "${S}"/whereis/pathnames.h || die
	sed -i -e '/^NO_SHARED/ s/^/#/' "${S}"/make/Makefile || die
}

src_install() {
	dragonfly_src_install

	dodir /bin
	for bin in sed; do
		mv "${D}/usr/bin/${bin}" "${D}/bin/" || die "mv ${bin} failed"
		dosym /bin/${bin} /usr/bin/${bin} || die "dosym ${bin} failed"
	done

	for pamdfile in login passwd su; do
		newpamd "${FILESDIR}/${pamdfile}.1.pamd" ${pamdfile} || die
	done

	cd "${WORKDIR}/${P}/etc"
	insinto /etc
	doins remote phones opieaccess fbtab || die

	exeinto /etc/cron.daily
	newexe "${FILESDIR}/locate-updatedb-cron" locate.updatedb || die
}

pkg_postinst() {
	if [[ -e "${ROOT}"etc/login.conf ]] ; then
		einfo "Updating ${ROOT}etc/login.conf.db"
		"${ROOT}"usr/bin/cap_mkdb	-f "${ROOT}"etc/login.conf "${ROOT}"etc/login.conf
		elog "Remember to run cap_mkdb /etc/login.conf after making changes to it"
	fi
}

pkg_postrm() {
	if [[ ! -e ${ROOT}/usr/bin/yacc ]] && [[ -e ${ROOT}/usr/bin/yacc.bison ]] ;then
		ln -s yacc.bison "${ROOT}"/usr/bin/yacc
	fi
}

