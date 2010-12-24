# /lib/rcscripts/addons/dm-crypt-stop.sh

# Fix for baselayout-1.12.10 (bug 174256)
: ${SVCNAME:=${myservice}}

# Try to remove any dm-crypt mappings
csetup=/sbin/cryptsetup
if [ -f /etc/conf.d/${SVCNAME} ] && [ -x "$csetup" ]
then
	einfo "Removing dm-crypt mappings"

	/bin/egrep "^(target|swap)" /etc/conf.d/${SVCNAME} | \
	while read targetline
	do
		target=
		swap=

		eval ${targetline}

		[ -n "${swap}" ] && target=${swap}
		[ -z "${target}" ] && ewarn "Invalid line in /etc/conf.d/${SVCNAME}: ${targetline}"

		ebegin "Removing dm-crypt mapping for: ${target}"
		${csetup} remove ${target}
		eend $? "Failed to remove dm-crypt mapping for: ${target}"
	done

	if [[ -n $(/bin/egrep -e "^(source=)./dev/loop*" /etc/conf.d/${SVCNAME}) ]] ; then
		einfo "Taking down any dm-crypt loop devices"
		/bin/egrep -e "^(source)" /etc/conf.d/${SVCNAME} | while read sourceline
		do
			source=
			eval ${sourceline}
			if [[ -n $(echo ${source} | grep /dev/loop) ]] ; then
				ebegin "   Taking down ${source}"
				/sbin/losetup -d ${source}
				eend $? "  Failed to remove loop"
			fi
		done
	fi
fi

# vim:ts=4
