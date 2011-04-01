EAPI=3
EDFLY_DIR="sys/boot"

inherit dragonfly

DESCRIPTION="DragonFly's bootloader"
SLOT="0"
KEYWORDS="~x86-dfbsd"

IUSE="bzip2 gzip nfs tftp"

RDEPEND=""
DEPEND="=sys-dfbsd/dfbsd-mk-defs-${PV}*
	=sys-dfbsd/dfbsd-lib-${PV}*"

PATCHES=( "${FILESDIR}"/${PN}-2.6.3-kgzldr.patch )

boot0_use_enable() {
	use ${1} && mymakeopts="${mymakeopts} LOADER_${2}_SUPPORT=\"yes\""
}

pkg_setup() {
	boot0_use_enable bzip2 BZIP2
	boot0_use_enable gzip GZIP
	boot0_use_enable nfs NFS
	boot0_use_enable tftp TFTP
}

src_prepare() {
	sed -e '/-fomit-frame-pointer/d' -e '/-mno-align-long-strings/d' \
		-i "${S}"/pc32/boot2/Makefile
}

src_compile() {
	strip-flags
	append-flags "-I/usr/include/libstand/"
	append-flags "-fno-strict-aliasing"
	NOFLAGSTRIP="yes" LDFLAGS="" dragonfly_src_compile
}

src_install() {
	dodir /boot/defaults
	mkinstall FILESDIR=/boot || die "mkinstall failed"
}
