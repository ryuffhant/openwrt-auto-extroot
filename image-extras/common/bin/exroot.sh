#!/bin/bash
clear
echo "OpenWRT Exroot"
echo ""

## requesting user input

echo "Available target devices in your system are :"
block info | grep -o -e "/dev/sd\S*"
sleep 2
clear
echo "Storage checking"
df -h
sleep 2
clear
echo "Please make sure your format partition is correct!"
echo "ext4 --> swap --> your choice"
sleep 2
clear
read -p "Are you sure want to continue? (answer by yes or not) " MODE_TARGET

if [ "$MODE_TARGET" = "yes" ]; then
	clear
	echo "wait until process finished..."
	uci -q delete fstab.overlay
	uci set fstab.overlay="mount"
	uci set fstab.overlay.device="/dev/sda1"
	uci set fstab.overlay.target="/overlay"
	uci set fstab.overlay.enabled='1'
	uci commit fstab
	uci -q delete fstab.swap
	uci set fstab.swap="swap"
	uci set fstab.swap.device="/dev/sda2"
	uci set fstab.swap.enabled='1'
	uci set fstab.@global[0].delay_root="5"
	uci commit fstab
	sleep 2
	clear
	echo "processing exroot"
	mount /dev/sda1 /mnt
	cp -a -f /overlay/. /mnt
	umount /mnt
	sleep 2
	clear
	echo "system rebooting..."
	sleep 3
	reboot
		else
	clear
	echo "canceled!"
	echo "system rebooting..."
	sleep 1
	reboot
fi
