EAPI=3
EDFLY_DIR=share

inherit bsdmk dragonfly

SLOT="0"
KEYWORDS="~x86-dfbsd"
IUSE="doc isdn"

DEPEND="=sys-dfbsd/dfbsd-mk-defs-${PV}*
	=sys-dfbsd/dfbsd-sources-${PV}*"
RDEPEND="sys-apps/miscfiles"

RESTRICT="strip"

PATCHES=( "${FILESDIR}"/${P}-doc-locations.patch
	"${FILESDIR}"/${P}-gentoo-skel.patch
	"${FILESDIR}"/${P}-gnu-miscfiles.patch 
	"${FILESDIR}"/${P}-colldef.patch 
	"${FILESDIR}"/${P}-monetdef.patch 
	"${FILESDIR}"/${P}-syscons.patch 
	"${FILESDIR}"/${P}-timedef.patch 
	"${FILESDIR}"/${P}-misc.patch 
	"${FILESDIR}"/${P}-csmapper.patch )
REMOVE_SUBDIRS="mk termcap zoneinfo tabset"

pkg_setup() {
	use isdn || mymakeopts="${mymakeopts} NO_I4B= "
	use doc || REMOVE_SUBDIRS="${REMOVE_SUBDIRS} doc"
	
	mymakeopts="${mymakeopts} NO_SENDMAIL= NOMANCOMPRESS= NOINFOCOMPRESS= "
}

src_unpack() {
	dragonfly_src_unpack

	cd "${WORKDIR}"/${P}
	epatch "${FILESDIR}"/${P}-examples.patch 

	cd "${S}"
	sed -i -e '/builtins\.1/d' "${S}/man/man1/Makefile" || die
	sed -i -e '/vesa.4/d' "${S}/man/man4/Makefile" || die
	sed -i -e 's:make.conf.5::' "${S}/man/man5/Makefile" || die
	sed -i -e 's:mailer.conf.5::' "${S}/man/man5/Makefile" || die
	sed -i -e 's:pbm.5::' -e 's:moduli.5::' "${S}/man/man5/Makefile" || die
	sed -i -e '/rc.8/d' "${S}/man/man8/Makefile" || die

	sed -i -e '/MANSUBDIR/d' "${S}"/man/man4/man4.i386/Makefile || die

	rm -rf "${S}"/mk/*.mk || die

	ln -s "/usr/src/sys-${PV}" "${WORKDIR}/sys" || die "failed to set sys symlink"
}

src_compile() {
	export ESED="/usr/bin/sed"

	export GROFF_TMAC_PATH="/usr/share/tmac/:/usr/share/groff/1.19.1/tmac/"
	mkmake || die "emake failed"
}

src_install() {
	mkmake -j1 DESTDIR="${D}" DOCDIR=/usr/share/doc/${PF} install \
		|| die "Install failed"
}

