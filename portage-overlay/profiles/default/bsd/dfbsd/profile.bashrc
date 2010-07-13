alias make=gmake
alias patch=gpatch
alias sed=gsed
alias awk=gawk

# Attempt to point the default SHELL used by configure scripts to bash.
# while most should work with BSD's bourne just fine, the extra scripts
# used by some applications (specially test scripts) use way too many bashisms.
export CONFIG_SHELL="/bin/bash"

# Hack to avoid every package that uses libiconv/gettext
# install a charset.alias that will collide with libiconv's one
# See bugs 169678, 195148 and 256129.
# Also the discussion on
# http://archives.gentoo.org/gentoo-dev/msg_8cb1805411f37b4eb168a3e680e531f3.xml
bsd-post_src_install()
{
	if [ "${PN}" != "libiconv" -a -e "${D}"/usr/lib*/charset.alias ] ; then
		rm -f "${D}"/usr/lib*/charset.alias
	fi
}

# These are because of
# http://archives.gentoo.org/gentoo-dev/msg_529a0806ed2cf841a467940a57e2d588.xml
# The profile-* ones are meant to be used in etc/portage/profile.bashrc by user
# until there is the registration mechanism.
profile-post_src_install() { bsd-post_src_install ; }
        post_src_install() { bsd-post_src_install ; }

if [[ ${EBUILD_PHASE} == "setup" ]] ; then
	hasq -static-libgcc ${CFLAGS} || export CFLAGS="${CFLAGS} -static-libgcc"
	hasq -static-libgcc ${CXXFLAGS} || export CFLAGS="${CXXFLAGS} -static-libgcc"
	
	
	if [[ -z ${ALLOWED_FLAGS} ]] ; then
		export ALLOWED_FLAGS="-pipe"
		export ALLOWED_FLAGS="${ALLOWED_FLAGS} -O -O0 -O1 -O2 -mcpu -march -mtune"
		export ALLOWED_FLAGS="${ALLOWED_FLAGS} -fstack-protector -fstack-protector-all"
		export ALLOWED_FLAGS="${ALLOWED_FLAGS} -fbounds-checking -fno-strict-overflow"
		export ALLOWED_FLAGS="${ALLOWED_FLAGS} -fno-PIE -fno-pie -fno-unit-at-a-time"
		export ALLOWED_FLAGS="${ALLOWED_FLAGS} -g -g[0-9] -ggdb -ggdb[0-9] -gstabs -gstabs+"
		export ALLOWED_FLAGS="${ALLOWED_FLAGS} -fno-ident"
		export ALLOWED_FLAGS="${ALLOWED_FLAGS} -W* -w"
		export ALLOWED_FLAGS="${ALLOWED_FLAGS} -static-libgcc"
	fi
fi

