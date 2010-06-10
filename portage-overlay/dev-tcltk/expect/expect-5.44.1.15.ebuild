# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-tcltk/expect/expect-5.44.1.15.ebuild,v 1.6 2010/05/25 11:01:58 jlec Exp $

EAPI="3"

WANT_AUTOCONF="2.5"
inherit autotools eutils

DESCRIPTION="tool for automating interactive applications"
HOMEPAGE="http://expect.nist.gov/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.bz2"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~x86-fbsd ~x86-freebsd ~amd64-linux ~x86-linux ~x86-macos ~x86-solaris"
IUSE="debug doc threads X"

# We need dejagnu for src_test, but dejagnu needs expect
# to compile/run, so we cant add dejagnu to DEPEND :/
DEPEND=">=dev-lang/tcl-8.2[threads?]
	X? ( >=dev-lang/tk-8.2[threads?] )"
RDEPEND="${DEPEND}"

src_prepare() {
	# fix install_name on darwin
	[[ ${CHOST} == *-darwin* ]] && \
		epatch "${FILESDIR}"/${P}-darwin.patch

	sed -i "s#/usr/local/bin#${EPREFIX}/usr/bin#" expect.man
	sed -i "s#/usr/local/bin#${EPREFIX}/usr/bin#" expectk.man
	#stops any example scripts being installed by default
	sed -i \
		-e '/^install:/s/install-libraries //' \
		-e 's/^SCRIPTS_MANPAGES = /_&/' \
		Makefile.in

	epatch "${FILESDIR}/${P}-gfbsd.patch"
	epatch "${FILESDIR}/${P}-ldflags.patch"
	epatch "${FILESDIR}/${P}_with-tk-no.patch"

	eautoconf
}

src_configure() {
	local myconf
	local tclv
	local tkv
	# Find the version of tcl/tk that has headers installed.
	# This will be the most recently merged, not necessarily the highest
	# version number.
	tclv=$(grep TCL_VER ${EPREFIX}/usr/include/tcl.h | sed 's/^.*"\(.*\)".*/\1/')
	#tkv isn't really needed, included for symmetry and the future
	#tkv=$(grep	 TK_VER ${EPREFIX}/usr/include/tk.h  | sed 's/^.*"\(.*\)".*/\1/')
	myconf="--with-tcl=${EPREFIX}/usr/$(get_libdir) --with-tclinclude=${EPREFIX}/usr/$(get_libdir)/tcl${tclv}/include/generic --with-tk=yes"

	if use X ; then
		#--with-x is enabled by default
		#configure needs to find the file tkConfig.sh and tk.h
		#tk.h is in /usr/lib so don't need to explicitly set --with-tkinclude
		myconf="$myconf --with-tk=${EPREFIX}/usr/$(get_libdir) --with-tkinclude=${EPREFIX}/usr/include"
	else
		#configure knows that tk depends on X so just disable X
		myconf="$myconf --with-tk=no"
	fi

	econf \
		$myconf \
		--enable-shared \
		$(use_enable threads) \
		$(use_enable amd64 64bit) \
		$(use_enable debug symbols)
}

src_test() {
	# we need dejagnu to do tests ... but dejagnu needs
	# expect ... so don't do tests unless we have dejagnu
	type -p runtest || return 0
	emake test || die "emake test failed"
}

src_install() {
	dodir /usr/$(get_libdir)
	emake install DESTDIR="${D}" || die "make install failed"

	dodoc ChangeLog FAQ HISTORY NEWS README

	#install examples if 'doc' is set
	if use doc ; then
		docinto examples
		local scripts=$(make -qp | \
			sed -e 's/^SCRIPTS = //' -et -ed | head -n1)
		insinto /usr/share/doc/${PF}/examples
		for s in ${scripts}; do
			doins example/${s} || die
		done
		local scripts_manpages=$(make -qp | \
		       sed -e 's/^_SCRIPTS_MANPAGES = //' -et -ed | head -n1)
		for m in ${scripts_manpages}; do
			dodoc example/${m}.man
		done
		dodoc example/README
	fi
}
