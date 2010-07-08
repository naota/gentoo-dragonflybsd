EAPI=3
EDFLY_DIR=lib/pam_module

inherit dragonfly multilib

SLOT="0"
KEYWORDS="~x86-dfbsd"
DESCRIPTION="DragonFly's PAM authenication modules"
IUSE="nis"

RDEPEND=">=sys-auth/openpam-20050201-r1"
DEPEND="${RDEPEND}
	=sys-dfbsd/dfbsd-mk-defs-${PV}*
	=sys-dfbsd/dfbsd-sources-${PV}*"

#REMOVE_SUBDIRS="pam_ssh pam_deny pam_passwdqc pam_permit"

pkg_setup() {
	use nis || mymakeopts="${mymakeopts} NO_NIS= "
}

src_unpack() {
	dragonfly_src_unpack
	
	cd "${S}"
	for mod in pam_ssh pam_deny pam_passwdqc pam_permit; do
		sed -i -e "/${mod}/d" Makefile || die
	done
	sed -i -e "/^TARGET_SHLIBDIR/s:/usr/lib/security:/$(get_libdir)/security:" \
		Makefile.inc || die
}

src_install() {
	dragonfly_src_install
	dodoc "${FILESDIR}"/README.pamd
}

