# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/gdb/gdb-7.1.ebuild,v 1.1 2010/03/19 02:21:14 vapier Exp $

inherit flag-o-matic eutils autotools

export CTARGET=${CTARGET:-${CHOST}}
if [[ ${CTARGET} == ${CHOST} ]] ; then
	if [[ ${CATEGORY/cross-} != ${CATEGORY} ]] ; then
		export CTARGET=${CATEGORY/cross-}
	fi
fi
is_cross() { [[ ${CHOST} != ${CTARGET} ]] ; }

PATCH_VER="1"
DESCRIPTION="GNU debugger"
HOMEPAGE="http://sources.redhat.com/gdb/"
SRC_URI="http://ftp.gnu.org/gnu/gdb/${P}.tar.bz2
	ftp://sources.redhat.com/pub/gdb/releases/${P}.tar.bz2
	${PATCH_VER:+mirror://gentoo/${P}-patches-${PATCH_VER}.tar.lzma}"

LICENSE="GPL-2 LGPL-2"
is_cross \
	&& SLOT="${CTARGET}" \
	|| SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sparc ~x86 ~x86-fbsd ~x86-dfbsd"
IUSE="expat multitarget nls python test vanilla"

RDEPEND=">=sys-libs/ncurses-5.2-r2
	sys-libs/readline
	expat? ( dev-libs/expat )
	python? ( dev-lang/python )"
DEPEND="${RDEPEND}
	|| ( app-arch/xz-utils app-arch/lzma-utils )
	=sys-devel/autoconf-2.64
	test? ( dev-util/dejagnu )
	nls? ( sys-devel/gettext )"

src_unpack() {
	unpack ${A}
	cd "${S}"
	if ! use vanilla ; then
		[[ -n ${PATCH_VER} ]] && EPATCH_SUFFIX="patch" epatch "${WORKDIR}"/patch
		use kernel_DragonFlyBSD && epatch "${FILESDIR}"/${P}-dragonfly-gdb-config.patch
		# http://leaf.dragonflybsd.org/cgi-bin/cgit/dragonfly.git/commit/?id=3749d171a17574885d8edd4e0ef8bc3f7bff45de&h=vendor/GMP
		epatch "${FILESDIR}"/${P}-dragonfly-gdb-i386fbsd-nat.patch
		epatch "${FILESDIR}"/${P}-dragonfly-gdb-bsd-kvm.patch
		cd "${S}"/gdb
		AT_NO_RECURSIVE=yes eautoreconf
		cd "${S}"
	fi
	strip-linguas -u bfd/po opcodes/po
}

gdb_branding() {
	printf "Gentoo ${PV} "
	if [[ -n ${PATCH_VER} ]] ; then
		printf "p${PATCH_VER}"
	else
		printf "vanilla"
	fi
}

src_compile() {
	strip-unsupported-flags
	econf \
		--with-pkgversion="$(gdb_branding)" \
		--with-bugurl='http://bugs.gentoo.org/' \
		--disable-werror \
		$(has_version '=sys-libs/readline-5*:0' && echo --with-system-readline) \
		$(is_cross && echo --with-sysroot=/usr/${CTARGET}) \
		$(use_with expat) \
		$(use_enable nls) \
		$(use multitarget && echo --enable-targets=all) \
		$(use_with python) \
		|| die
	emake || die
}

src_test() {
	emake check || ewarn "tests failed"
}

src_install() {
	emake \
		DESTDIR="${D}" \
		libdir=/nukeme/pretty/pretty/please includedir=/nukeme/pretty/pretty/please \
		install || die
	rm -r "${D}"/nukeme || die

	# Don't install docs when building a cross-gdb
	if [[ ${CTARGET} != ${CHOST} ]] ; then
		rm -r "${D}"/usr/share
		return 0
	fi

	dodoc README
	docinto gdb
	dodoc gdb/CONTRIBUTE gdb/README gdb/MAINTAINERS \
		gdb/NEWS gdb/ChangeLog gdb/PROBLEMS
	docinto sim
	dodoc sim/ChangeLog sim/MAINTAINERS sim/README-HACKING

	dodoc "${WORKDIR}"/extra/gdbinit.sample

	# Remove shared info pages
	rm -f "${D}"/usr/share/info/{annotate,bfd,configure,standards}.info*
}

pkg_postinst() {
	# portage sucks and doesnt unmerge files in /etc
	rm -vf "${ROOT}"/etc/skel/.gdbinit
}
