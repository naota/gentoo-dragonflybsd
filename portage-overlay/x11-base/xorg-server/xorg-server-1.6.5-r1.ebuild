# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-base/xorg-server/xorg-server-1.6.5-r1.ebuild,v 1.10 2010/04/09 10:28:58 scarabeus Exp $

EAPI="2"

# Must be before x-modular eclass is inherited
#SNAPSHOT="yes"

inherit x-modular multilib versionator

SRC_URI="${SRC_URI}
	mirror://gentoo/${P}-gentoo-patches-01.tar.bz2"

OPENGL_DIR="xorg-x11"

DESCRIPTION="X.Org X servers"
KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc ppc64 sh sparc x86 ~x86-fbsd"

IUSE_SERVERS="dmx kdrive xorg"
IUSE="${IUSE_SERVERS} tslib hal ipv6 minimal nptl sdl"

RDEPEND="
	hal? ( sys-apps/hal )
	tslib? ( >=x11-libs/tslib-1.0 x11-proto/xcalibrateproto )
	dev-libs/openssl
	>=x11-libs/libXfont-1.4.0
	>=x11-libs/xtrans-1.2.3
	>=x11-libs/libXau-1.0.4
	>=x11-libs/libXext-1.0.4
	>=x11-libs/libX11-1.1.5
	>=x11-libs/libxkbfile-1.0.4
	>=x11-libs/libXdmcp-1.0.2
	>=x11-libs/libXmu-1.0.3
	>=x11-libs/libXrender-0.9.4
	>=x11-libs/libXi-1.2.1
	>=x11-libs/pixman-0.14.0
	media-libs/freetype
	>=x11-misc/xbitmaps-1.0.1
	>=x11-misc/xkeyboard-config-1.4
	x11-apps/xkbcomp
	>=x11-apps/iceauth-1.0.2
	>=x11-apps/rgb-1.0.3
	>=x11-apps/xauth-1.0.3
	<=x11-apps/xinit-1.2.1
	>=app-admin/eselect-opengl-1.0.8
	>=x11-libs/libXaw-1.0.5
	>=x11-libs/libXpm-3.5.7
	>=x11-libs/libpciaccess-0.10.3
	dmx? (
		>=x11-libs/libdmx-1.0.2
		>=x11-libs/libXfixes-4.0.3
	)
	!minimal? (
		>=x11-libs/libXtst-1.0.3
		>=x11-libs/libXres-1.0.3
		>=media-libs/mesa-7.3_rc1[nptl=]
	)
	>=x11-libs/libxkbui-1.0.2
	kdrive? ( sdl? ( media-libs/libsdl ) )"
	# Xres is dmx-dependent
	# Xaw is dmx-dependent
	# Xpm is dmx-dependent, pulls in Xt
	# xkbcomp is launched at startup but not checked by ./configure
DEPEND="${RDEPEND}
	!net-dialup/dtrace
	sys-devel/flex
	>=x11-proto/randrproto-1.2.99.4
	>=x11-proto/renderproto-0.9.3
	>=x11-proto/fixesproto-4
	>=x11-proto/damageproto-1.1
	>=x11-proto/xextproto-7.0.4
	>=x11-proto/xproto-7.0.14
	>=x11-proto/xf86dgaproto-2.0.3
	>=x11-proto/xf86rushproto-1.1.2
	>=x11-proto/xf86vidmodeproto-2.2.2
	>=x11-proto/compositeproto-0.4
	>=x11-proto/recordproto-1.13.2
	>=x11-proto/resourceproto-1.0.2
	>=x11-proto/videoproto-2.2.2
	>=x11-proto/scrnsaverproto-1.1.0
	>=x11-proto/trapproto-3.4.3
	>=x11-proto/xineramaproto-1.1.2
	>=x11-proto/fontsproto-2.0.2
	>=x11-proto/kbproto-1.0.3
	>=x11-proto/inputproto-1.5.0
	>=x11-proto/bigreqsproto-1.0.2
	>=x11-proto/xcmiscproto-1.1.2
	>=x11-proto/glproto-1.4.9
	dmx? ( >=x11-proto/dmxproto-2.2.2 )
	!minimal? (
		>=x11-proto/xf86driproto-2.0.4
		>=x11-proto/dri2proto-2.1
		>=x11-libs/libdrm-2.3
	)"

PDEPEND="xorg? ( >=x11-base/xorg-drivers-$(get_version_component_range 1-2) )"
LICENSE="${LICENSE} MIT"

EPATCH_FORCE="yes"
EPATCH_SUFFIX="patch"

# These have been sent upstream
UPSTREAMED_PATCHES=(
	"${WORKDIR}/patches/"
	)

PATCHES=(
	"${UPSTREAMED_PATCHES[@]}"
	)

pkg_setup() {
	use minimal || ensure_a_server_is_building

	# SDL only available in kdrive build
	if use kdrive && use sdl; then
		conf_opts="${conf_opts} --enable-xsdl"
	else
		conf_opts="${conf_opts} --disable-xsdl"
	fi

	# localstatedir is used for the log location; we need to override the default
	# from ebuild.sh
	# sysconfdir is used for the xorg.conf location; same applies
	# --enable-install-setuid needed because sparcs default off
	CONFIGURE_OPTIONS="
		$(use_enable ipv6)
		$(use_enable dmx)
		$(use_enable kdrive)
		$(use_enable tslib)
		$(use_enable tslib xcalibrate)
		$(use_enable !minimal xvfb)
		$(use_enable !minimal xnest)
		$(use_enable !minimal record)
		$(use_enable !minimal xfree86-utils)
		$(use_enable !minimal install-libxf86config)
		$(use_enable !minimal dri)
		$(use_enable !minimal dri2)
		$(use_enable !minimal glx)
		$(use_enable xorg)
		$(use_enable nptl glx-tls)
		$(use_enable hal config-hal)
		--sysconfdir=/etc/X11
		--localstatedir=/var
		--enable-install-setuid
		--with-fontdir=/usr/share/fonts
		--with-xkb-output=/var/lib/xkb
		--without-dtrace
		${conf_opts}"

	# (#121394) Causes window corruption
	filter-flags -fweb

	# Incompatible with GCC 3.x SSP on x86, bug #244352
	if use x86 ; then
		if [[ $(gcc-major-version) -lt 4 ]]; then
			filter-flags -fstack-protector
		fi
	fi

	OLD_IMPLEM="$(eselect opengl show)"
	eselect opengl set ${OPENGL_DIR}
}

src_install() {
	x-modular_src_install

	dynamic_libgl_install

	server_based_install

	# Install video mode files for system-config-display
	insinto /usr/share/xorg
	doins hw/xfree86/common/{extra,vesa}modes \
		|| die "couldn't install extra modes"

	# Bug #151421 - this file is not built with USE="minimal"
	# Bug #151670 - this file is also not build if USE="-xorg"
	if ! use minimal &&	use xorg; then
		# Install xorg.conf.example
		insinto /etc/X11
		doins hw/xfree86/xorg.conf.example \
			|| die "couldn't install xorg.conf.example"
	fi
}

pkg_postinst() {
	switch_opengl_implem

	# Bug #135544
	ewarn "Users of reduced blanking now need:"
	ewarn "   Option \"ReducedBlanking\""
	ewarn "In the relevant Monitor section(s)."
	ewarn "Make sure your reduced blanking modelines are safe!"

	echo
	ewarn "You must rebuild all drivers if upgrading from xorg-server 1.5"
	ewarn "or earlier, because the ABI changed. If you cannot start X because"
	ewarn "of module version mismatch errors, this is your problem."

	echo
	ewarn "You can generate a list of all installed packages in the x11-drivers"
	ewarn "category using this command:"
	ewarn "emerge portage-utils; qlist -I -C x11-drivers/"

	ebeep 5
	epause 10
}

pkg_postrm() {
	# Get rid of module dir to ensure opengl-update works properly
	if ! has_version x11-base/xorg-server; then
		if [[ -e ${ROOT}/usr/$(get_libdir)/xorg/modules ]]; then
			rm -rf "${ROOT}"/usr/$(get_libdir)/xorg/modules
		fi
	fi
}

dynamic_libgl_install() {
	# next section is to setup the dynamic libGL stuff
	ebegin "Moving GL files for dynamic switching"
		dodir /usr/$(get_libdir)/opengl/${OPENGL_DIR}/extensions
		local x=""
		for x in "${D}"/usr/$(get_libdir)/xorg/modules/extensions/lib{glx,dri,dri2}*; do
			if [ -f ${x} -o -L ${x} ]; then
				mv -f ${x} "${D}"/usr/$(get_libdir)/opengl/${OPENGL_DIR}/extensions
			fi
		done
	eend 0
}

server_based_install() {
	if ! use xorg; then
		rm "${D}"/usr/share/man/man1/Xserver.1x \
			"${D}"/usr/$(get_libdir)/xserver/SecurityPolicy \
			"${D}"/usr/$(get_libdir)/pkgconfig/xorg-server.pc \
			"${D}"/usr/share/man/man1/Xserver.1x
	fi
}

switch_opengl_implem() {
		# Switch to the xorg implementation.
		# Use new opengl-update that will not reset user selected
		# OpenGL interface ...
		echo
		eselect opengl set ${OLD_IMPLEM}
}

ensure_a_server_is_building() {
	for server in ${IUSE_SERVERS}; do
		use ${server} && return;
	done
	eerror "You need to specify at least one server to build."
	eerror "Valid servers are: ${IUSE_SERVERS}."
	die "No servers were specified to build."
}
