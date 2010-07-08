EAPI=3
EDFLY_DIR="gnu"

inherit dragonfly

DESCRIPTION="Contributed source for DragonFly BSD"
SLOT="0"
KEYWORDS="~x86-dfbsd"

RDEPEND=""
DEPEND="=sys-dfbsd/dfbsd-sources-${PV}*
	=sys-dfbsd/dfbsd-mk-defs-${PV}*"

PATCHES=( "${FILESDIR}"/${P}-libdialog.patch 
	"${FILESDIR}"/${P}-sort-zopt.patch )

src_compile() {
	for x in lib/libdialog usr.bin/sort; do
		cd "${S}"/$x
		dragonfly_src_compile
	done
}

src_install() {
	use profile || mymakeopts="${mymakeopts} NOPROFILE= "
	mymakeopts="${mymakeopts} NOMANCOMPRESS= NOINFOCOMPRESS= "

	cd "${S}"/lib/libdialog
	mkinstall || die

	cd "${S}"/usr.bin/sort
	mkinstall BINDIR="/bin/" || die
}
