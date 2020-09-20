#!/bin/bash
# OpenWRT/LEDE Exroot Builder -- alpha

# open fd
exec 3>&1

# Store data to $NAME variable
NAME=$(dialog --backtitle "OpenWRT/LEDE Exroot Generator" \
--inputbox "Enter name " 8 50 \
2>&1 1>&3)

# Store data to $REL variable
REL=$(dialog --backtitle "OpenWRT/LEDE Exroot Generator" \
--inputbox "Enter version " 8 50 \
2>&1 1>&3)

# Store data to $ARCH variable
ARCH=$(dialog --backtitle "OpenWRT/LEDE Exroot Generator" \
--inputbox "Enter architecture " 8 50 \
2>&1 1>&3)

# Store data to $VAR variable
VAR=$(dialog --backtitle "OpenWRT/LEDE Exroot Generator" \
--inputbox "Enter target " 8 50 \
2>&1 1>&3)

# Store data to $DEV variable
DEV=$(dialog --backtitle "OpenWRT/LEDE Exroot Generator" \
--inputbox "Enter device " 8 50 \
2>&1 1>&3)

# close fd
exec 3>&-

dialog --backtitle "OpenWRT/LEDE Exroot Builder" \
--yesno "Are you sure want to continue?" 8 50
response=$?
case $response in
	0)
		clear
		echo "Please be patient!"
		sleep 3
		clear
			set -e
			absolutize ()
				{
					if [ ! -d "$1" ]; then
						echo
						echo "ERROR: '$1' doesn't exist or not a directory!"
						kill -INT $$
					fi

					pushd "$1" >/dev/null
					echo `pwd`
					popd >/dev/null
				}

		TARGET_ARCHITECTURE=${ARCH}
		TARGET_VARIANT=${VAR}
		TARGET_DEVICE=${DEV}
		RELEASE=${REL}
		TARGET_NAME=${NAME}
		BUILD=`dirname "$0"`"/build/"
		BUILD=`absolutize $BUILD`
		IMGBUILDER_NAME="${TARGET_NAME}-imagebuilder-${RELEASE}-${TARGET_ARCHITECTURE}-${TARGET_VARIANT}.Linux-x86_64"
		IMGBUILDER_DIR="${BUILD}/${IMGBUILDER_NAME}"
		IMGBUILDER_ARCHIVE="${IMGBUILDER_NAME}.tar.xz"
		IMGTEMPDIR="${BUILD}/image-extras"
		IMGBUILDERURL="https://downloads.openwrt.org/releases/${RELEASE}/targets/${TARGET_ARCHITECTURE}/${TARGET_VARIANT}/${IMGBUILDER_ARCHIVE}"
		IMGDONE="${BUILD}/completed"

		# the absolute minimum for extroot to work at all (i.e. when the disk is already set up, for example by hand).
		# this list may be smaller and/or different for your router, but it works with my ar71xx.
		PREINSTALLED_PACKAGES="block-mount kmod-fs-ext4 kmod-usb-storage kmod-usb-ohci kmod-usb-uhci nano"

		# Feel free to use IPv6 installed by default or remove it.
		PREINSTALLED_PACKAGES+=" -ppp -ppp-mod-pppoe -ip6tables -odhcp6c -kmod-ipv6 -kmod-ip6tables -odhcpd-ipv6only"

		# these are needed for the proper functioning of the auto extroot scripts
		#PREINSTALLED_PACKAGES+=" blkid mount-utils swap-utils e2fsprogs fdisk"

		# the following packages are optional, feel free to (un)comment them
		#PREINSTALLED_PACKAGES+=" wireless-tools firewall iptables"
		#PREINSTALLED_PACKAGES+=" kmod-usb-storage-extras kmod-mmc"
		#PREINSTALLED_PACKAGES+=" ppp ppp-mod-pppoe ppp-mod-pppol2tp ppp-mod-pptp kmod-ppp kmod-pppoe"
		#PREINSTALLED_PACKAGES+=" luci"

		mkdir -pv ${BUILD}

					if [ ! -e ${IMGDONE} ]; then
						mkdir -p ${IMGDONE}
					fi

		rm -rf $IMGTEMPDIR
		cp -r image-extras/common/ $IMGTEMPDIR
		PER_PLATFORM_IMAGE_EXTRAS=image-extras/${TARGET_DEVICE}/
					if [ -e $PER_PLATFORM_IMAGE_EXTRAS ]; then
						rsync -pr $PER_PLATFORM_IMAGE_EXTRAS $IMGTEMPDIR/
					fi

					if [ ! -e ${IMGBUILDER_DIR} ]; then
						pushd ${BUILD}
						# --no-check-certificate if needed
						wget --continue ${IMGBUILDERURL}
						xz -d <${IMGBUILDER_ARCHIVE} | tar vx
						popd
					fi

		pushd ${IMGBUILDER_DIR}
		make image PROFILE=${TARGET_DEVICE} PACKAGES="${PREINSTALLED_PACKAGES}" FILES=${IMGTEMPDIR}
		popd
		cp -f ${IMGBUILDER_DIR}/build_dir/target-*/linux-${ARCH}_${VAR}/tmp/${NAME}-${REL}-${ARCH}-${VAR}-${DEV}-squashfs-{factory,sysupgrade}.bin ${IMGDONE}
		clear
		echo "Build completed"
		echo "Check on ${IMGDONE} folder"
	;;
1)
		dialog --title "INFO" --msgbox "Proccess has been aborted!" 8 50
		clear
	;;
255)
		dialog --title "INFO" --msgbox "[ESC] key pressed. Proccess has been aborted!" 8 50
		clear
	;;
esac
