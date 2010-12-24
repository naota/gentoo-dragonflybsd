# /lib/rcscripts/addons/lvm-stop.sh
# $Header: /var/cvsroot/gentoo-x86/sys-fs/lvm2/files/lvm2-stop.sh,v 1.6 2007/10/04 16:06:22 cardoe Exp $

# Stop LVM2
if [ -x /sbin/vgchange ] && \
   [ -x /sbin/lvdisplay ] && \
   [ -x /sbin/vgdisplay ] && \
   [ -x /sbin/lvchange ] && \
   [ -f /etc/lvmtab -o -d /etc/lvm ] && \
   [ -d /proc/lvm  -o "`grep device-mapper /proc/misc 2>/dev/null`" ]
then
	einfo "Shutting down the Logical Volume Manager"
	# If these commands fail it is not currently an issue
	# as the system is going down anyway based on the current LVM 
	# functionality as described in this forum thread
	#https://www.redhat.com/archives/linux-lvm/2001-May/msg00523.html

	LOGICAL_VOLUMES=`lvdisplay |grep "LV Name"|sed -e 's/.*LV Name\s*\(.*\)/\1/'|sort`
	VOLUME_GROUPS=`vgdisplay |grep "VG Name"|sed -e 's/.*VG Name\s*\(.*\)/\1/'|sort`
	for x in ${LOGICAL_VOLUMES}
	do
		LV_IS_ACTIVE=`lvdisplay ${x}|grep "# open"|awk '{print $3}'`
		if [ "${LV_IS_ACTIVE}" = 0 ]
		then
			ebegin "  Shutting Down logical volume: ${x} "
			lvchange -an --ignorelockingfailure -P ${x} >/dev/null
			eend $?
		fi
	done

	for x in ${VOLUME_GROUPS}
	do
		VG_HAS_ACTIVE_LV=`vgdisplay ${x}|grep "Open LV"|sed -e 's/.*Open LV\s*\(.*\)/\1/'`
		if [ "${VG_HAS_ACTIVE_LV}" = 0 ]
		then
			ebegin "  Shutting Down volume group: ${x} "
			vgchange -an --ignorelockingfailure -P ${x} >/dev/null
			eend
		fi
	done

	for x in ${LOGICAL_VOLUMES}
	do
		LV_IS_ACTIVE=`lvdisplay ${x}|grep "# open"|sed -e 's/.*# open\s*\(.*\)/\1/'`
		if [ "${LV_IS_ACTIVE}" = 1 ]
		then
			
			ROOT_DEVICE=`mount|grep " / "|awk '{print $1}'`
			MOUNTED_DEVICE=${x}
			[ -L ${ROOT_DEVICE} ] && ROOT_DEVICE="`/bin/readlink ${ROOT_DEVICE}`"
			[ -L ${x} ] && MOUNTED_DEVICE="`/bin/readlink ${x}`"
			if [ ! ${ROOT_DEVICE} = ${MOUNTED_DEVICE} ]
			then
				ewarn "  Unable to shutdown: ${x} "
			fi
		fi
	done
	einfo "Finished Shutting down the Logical Volume Manager"
fi

# vim:ts=4
