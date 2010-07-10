# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2
EDFLY_DIR=sys

inherit dragonfly

DESCRIPTION="DragonFly kernel sources"

SLOT="${PVR}"
KEYWORDS="~x86-dfbsd"
IUSE="symlink"

RESTRICT="strip binchecks"

PATCHES=(
	"${FILESDIR}"/${P}-werror.patch
	"${FILESDIR}"/${P}-config.patch
)

src_unpack() {
	dragonfly_src_unpack

	sed -i -e 's:^REVISION=.*:REVISION="'${PVR}'":' \
		-e 's:^BRANCH=.*:BRANCH="Gentoo":' \
		-e 's:^VERSION=.*:VERSION="${TYPE} ${BRANCH} ${REVISION}":' \
		conf/newvers.sh || die "Set version failed"
}

src_compile() { :; }

src_install() {
	if [[ ${CHOST} != *-dragonfly* ]]; then
		insinto "/usr/src/dragonfly-sys-${PVR}"
	else
		insinto "/usr/src/sys-${PVR}"
	fi
	doins -r "${S}"/*
}

pkg_postinst() {
	if [[ ! -L "${ROOT}/usr/src/sys/" ]]; then
		einfo "/usr/src/sys symlink doesn't exist; creating symlink to sys-${PVR}..."
		ln -sf "sys-${PVR}" "${ROOT}"/usr/src/sys || \
			eerror "Couldn't create ${ROOT}/usr/src/sys symlink."
		[[ -L "${ROOT}/usr/src/sys-${RV}" ]] && rm "${ROOT}/usr/src/sys-${RV}"
		ln -sf "sys-${PVR}" "${ROOT}"/usr/src/sys-${RV} || \
			eerror "Couldn't create ${ROOT}/usr/src/sys-${RV} symlink."
	elif use symlink; then
		einfo "Updating /usr/src/sys symlink to sys-${PVR}..."
		rm "${ROOT}/usr/src/sys" "${ROOT}/usr/src/sys-${RV}" || \
			eerror "Couldn't remove the previous symlinks, please fix manually."
		ln -sf "sys-${PVR}" "${ROOT}"/usr/src/sys || \
			eerror "Couldn't create ${ROOT}/usr/src/sys symlink."
		[[ -L "${ROOT}/usr/src/sys-${RV}" ]] && rm "${ROOT}/usr/src/sys-${RV}"
		ln -sf "sys-${PVR}" "${ROOT}"/usr/src/sys-${RV} || \
			eerror "Couldn't create ${ROOT}/usr/src/sys-${RV} symlink."
	fi
}

