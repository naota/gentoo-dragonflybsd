# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3
EGIT_REPO_URI="git://git.dragonflybsd.org/dragonfly.git"
EGIT_COMMIT="v2.6.3"
EGIT_PROJECT="dragonflybsd"

inherit git bsdmk freebsd

DESCRIPTION="DragonFly sbin utils"
HOMEPAGE="http://www.dragonflybsd.org/"

LICENSE=""
SLOT="0"
KEYWORDS="~x86-dfbsd"
IUSE="ipfilter pf"

RDEPEND=""
DEPEND="=sys-dfbsd/dfbsd-sources-${PV}*
	=sys-dfbsd/dfbsd-mk-defs-${PV}*"

PROVIDE="virtual/libc
	virtual/os-headers"

REMOVE_SUBDIRS="libncurses
	libz libbz2 libarchive \
	libsm libsmdb libsmutil \
	libbegemot libbsnmp \
	libpam libpcap bind libwrap libmagic \
	libcom_err libtelnet
	libedit libelf libisc"

pkg_setup() {
	[ -c /dev/zero ] || \
		die "You forgot to mount /dev; the compiled libc would break."
	mymakeopts="${mymakeopts} WITHOUT_BIND= WITHOUT_BIND_LIBS= WITHOUT_SENDMAIL="
}

src_unpack() {
	git_src_unpack
	S="${WORKDIR}/${P}/lib"
	cd ${S}
	dummy_mk ${REMOVE_SUBDIRS}
	freebsd_rename_libraries

	epatch "${FILESDIR}"/${P}-csu.patch

	sed -i.bak -e 's/iconv.h//' "${WORKDIR}"/${P}/include/Makefile
	sed -i.bak -e '/^MAN/d;/^MLINK/d' "${S}"/libc/iconv/Makefile.inc
	
	sed -i.bak -e 's:-o/dev/stdout:-t:' "${S}/libc/net/Makefile.inc" || die
	sed -i.bak -e 's:histedit.h::' "${WORKDIR}/${P}/include/Makefile" || die

	local x=
	for x in "${WORKDIR}"/${P}/etc/etc.*/ttys ; do
		sed -i.bak \
			-e '/ttyv5[[:space:]]/ a\
# Display Managers default to VT7.\
# If you use the xdm init script, keep ttyv6 commented
# out\
# unless you force a different VT for the DM being
# used.' \
			-e '/^ttyv[678][[:space:]]/ s/^/# /' "${x}" \
			|| die "Failed to sed ${x}"
		rm "${x}".bak
	done

	rm "${WORKDIR}"/${P}/include/hesiod.h || die
	sed -i.bak -e 's:hesiod.h::' "${WORKDIR}"/${P}/include/Makefile || die
	sed -i.bak -e 's:hesiod.c::' -e 's:hesiod.3::' \
		"${WORKDIR}"/${P}/lib/libc/net/Makefile.inc || die

	cd "${S}"
	for dir in libarchive libedit; do
		sed -i.bak -e 's:LDADD=:LDADD+=:g' "${dir}/Makefile"	|| \
			die "Problem fixing \"${dir}/Makefile"
	done

	ln -s "/usr/src/sys-${RV}" "${WORKDIR}/${P}/sys" || die "Couldn't make sys symlink!"

	if install --version 2> /dev/null | grep -q GNU; then
		sed -i.bak -e 's:${INSTALL} -C:${INSTALL}:' "${WORKDIR}/${P}/include/Makefile"
	fi

	sed -i.bak -e 's:${DESTDIR}/usr/include:${DESTDIR}/${INCLUDEDIR}:g' \
		"${WORKDIR}"/${P}/include/Makefile

	mkdir "${WORKDIR}/${P}/include_proper" || die "Couldn't create ${WORKDIR}/${P}/include_proper"
	install_includes "/include_proper"

	local machine
	machine=$(tc-arch-kernel ${CTARGET})
	ln -s "${WORKDIR}/${P}/sys/${machine}/include" "${WORKDIR}/${P}/include/machine" || \
		die "Couldn't make ${machine}/include symlink."

	local mylibdir=$(get_libdir)
	sed -i.bak -e "/^LIBDIR/d" \
		"${WORKDIR}"/${P}/lib/libc_r/Makefile \
		"${WORKDIR}"/${P}/lib/libthread_xu/Makefile || die
	echo "LIBDIR=/usr/${mylibdir}/thread" >> "${WORKDIR}"/${P}/lib/libc_r/Makefile 
	echo "SHLIBDIR=/${mylibdir}/thread" >> "${WORKDIR}"/${P}/lib/libc_r/Makefile 
	echo "LIBDIR=/usr/${mylibdir}/thread" >> "${WORKDIR}"/${P}/lib/libthread_xu/Makefile 
	echo "SHLIBDIR=/${mylibdir}/thread" >> "${WORKDIR}"/${P}/lib/libthread_xu/Makefile 
}

src_compile() {
	cd "${WORKDIR}/${P}/include"
	$(freebsd_get_bmake) CC="$(tc-getCC)" || die "make include failed"

	append-flags "-isystem '${WORKDIR}/${P}/include_proper'"

	einfo "Compiling libc."
	cd "${S}"
	NOFLAGSTRIP=yes freebsd_src_compile
}

src_install() {
	INCLUDEDIR="/usr/include"
	dodir ${INCLUDEDIR}
	einfo "Installing for ${CTARGET} in ${CHOST}.."
	install_includes ${INCLUDEDIR}

	local mylibdir=$(get_libdir)

	cd "${WORKDIR}/${P}/lib"
	SHLIBDIR="/${mylibdir}" LIBDIR="/usr/${mylibdir}" NOFSCHG=yes mkinstall || die "Install failed"

	dodir /usr/include/libstand
	insinto /usr/include/libstand
	doins "${WORKDIR}"/${P}/lib/libstand/*.h

	cd "${WORKDIR}/${P}/etc/"
	insinto /etc
	doins auth.conf nls.alias netconfig

	local MACHINE="$(tc-arch-kernel)"

	gen_usr_ldscript libalias.so libatm.so libbind9.so libbluetooth.so \
		libbsdxml.so libc.so libcalendar.so libcam.so libcrypt.so \
		libdevinfo.so libdevstat.so libevent.so libevtr.so libfetch.so libform.so \
		libftpio.so libipsec.so libipx.so libkcore.so libkiconv.so libkinfo.so \
		libkvm.so libm.so libmd.so libmenu.so libmilter.so libmytinfo.so libncp.so \
		libnetgraph.so libopie.so libpanel.so libposix1e.so \
		libpthread.so libradius.so librpcsvc.so librt.so libsbuf.so libsctp.so \
		libsdp.so libsmb.so libtacplus.so libtermcap.so	libtermlib.so libtinfo.so \
		libusbhid.so libutil.so libvgl.so libxpg4.so libypclnt.so
		thread/libthread_xu.so thread/libc_r.so 
}

install_includes()
{
	local INCLUDEDIR="$1"

	# The idea is to be called from either install or unpack.
	# During unpack it's required to install them as portage's user.
	if [[ "${EBUILD_PHASE}" == "install" ]]; then
		local DESTDIR="${D}"
		BINOWN="root"
		BINGRP="wheel"
	else
		local DESTDIR="${WORKDIR}"/${P}
		[[ -z "${USER}" ]] && USER="portage"
		BINOWN="${USER}"
		[[ -z "${GROUPS}" ]] && GROUPS="portage"
		BINGRP="${GROUPS}"
	fi

	# Must exist before we use it.
	[[ -d "${DESTDIR}${INCLUDEDIR}" ]] || die "dodir or mkdir ${INCLUDEDIR} before using install_includes."
	cd "${WORKDIR}/${P}/include"

	if [[ $(tc-arch-kernel) == "x86_64" ]]; then
		local MACHINE="amd64"
	else
		local MACHINE="$(tc-arch-kernel)"
	fi

	einfo "Installing includes into ${INCLUDEDIR} as ${BINOWN}:${BINGRP}..."
	$(freebsd_get_bmake) installincludes \
		MACHINE=${MACHINE} DESTDIR="${DESTDIR}" \
		INCLUDEDIR="${INCLUDEDIR}" BINOWN="${BINOWN}" \
		BINGRP="${BINGRP}" || die "install_includes() failed"
	einfo "includes installed ok."
}
