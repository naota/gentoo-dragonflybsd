# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EGIT_REPO_URI="git://git.dragonflybsd.org/dragonfly.git"
EGIT_COMMIT="v${PV}"
EGIT_PROJECT="dragonflybsd"

inherit freebsd git bsdmk

HOMEPAGE="http://www.dragonflybsd.org/"

# Define global package names
LIB="dfbsd-lib-${PV}"
BIN="dfbsd-bin-${PV}"
CONTRIB="dfbsd-contrib-${PV}"
SHARE="dfbsd-share-${PV}"
UBIN="dfbsd-ubin-${PV}"
USBIN="dfbsd-usbin-${PV}"
CRYPTO="dfbsd-crypto-${PV}"
LIBEXEC="dfbsd-libexec-${PV}"
SBIN="dfbsd-sbin-${PV}"
GNU="dfbsd-gnu-${PV}"
ETC="dfbsd-etc-${PV}"
SYS="dfbsd-sys-${PV}"
INCLUDE="dfbsd-include-${PV}"
RESCUE="dfbsd-rescue-${PV}"
CDDL="dfbsd-cddl-${PV}"

RV=""

if [[ ${PN} != "dfbsd-share" ]] && [[ ${PN} != "dfbsd-sources" ]]; then
	IUSE="profile"
fi

EXPORT_FUNCTIONS src_unpack src_compile src_install

dragonfly_get_bmake() {
	local bmake
	bmake=$(get_bmake)
	[[ ${CBUILD} == *-dragonfly* ]] || bmake="${bmake} -m /usr/share/mk/dragonfly"
	echo ${bmake}
}

dragonfly_src_unpack() {
	git_src_unpack
	S="${S}"/${EDFLY_DIR}
	cd "${S}"
	dummy_mk ${REMOVE_SUBDIRS}
	freebsd_do_patches
	freebsd_rename_libraries
}

dragonfly_src_compile() {
	use profile && filter-flags "-fomit-frame-pointer"
	use profile || mymakeopts="${mymakeopts} NOPROFILE= "

	mymakeopts="${mymakeopts} NOMANCOMPRESS= NOINFOCOMPRESS="

	[[ -z "${NOFLAGSTRIP}" ]] && strip-flags

	[[ -z "${BMAKE}" ]] && BMAKE="$(dragonfly_get_bmake)"

	NOFSCHG= bsdmk_src_compile
}

dragonfly_src_install() {
	use profile || mymakeopts="${mymakeopts} NOPROFILE= "

	mymakeopts="${mymakeopts} NOMANCOMPRESS= NOINFOCOMPRESS="

	[[ -z "${BMAKE}" ]] && BMAKE="$(dragonfly_get_bmake)"

	NOFSCHG= bsdmk_src_install
}

#
# Original Author: Naohiro Aota <naota@elisp.net>
# Purpose: 
#

