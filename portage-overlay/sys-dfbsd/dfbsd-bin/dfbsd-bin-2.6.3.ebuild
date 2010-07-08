EAPI=3
EDFLY_DIR="bin"

inherit dragonfly flag-o-matic

DESCRIPTION="DragonFly /bin tools"
SLOT="0"
KEYWORDS="~x86-dfbsd"

RDEPEND="=sys-dfbsd/dfbsd-lib-${PV}*
	dev-libs/libedit
	sys-libs/ncurses"
DEPEND="${RDEPEND}
	=sys-dfbsd/dfbsd-mk-defs-${PV}*"

PATCHES=( "${FILESDIR}"/${P}-Makefile.patch )
REMOVE_SUBDIRS="csh rmail ed"

pkg_setup() {
	mymakeopts="${mymakeopts} NO_SENDMAIL= "

	append-flags $(test-flags -static-libgcc)
}

