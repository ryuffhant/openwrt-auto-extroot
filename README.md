# OpenWRT/LEDE Image Generator

It's a script to generate build a customized OpenWRT firmware image on a Linux x86_64 host
(basic familiarity with [OpenWRT](https://wiki.openwrt.org/doc/howto/user.beginner)
is assumed) using image builder.

Generated firmware image support for **exroot** also strip **IPv6, PPOE** and without `LuCI`.
For more information about set up please follow this instruction [extroot](http://wiki.openwrt.org/doc/howto/extroot). Unfortunately there's little that can be done at that point to ask the user for confirmation.

# Why

So that e.g. customers can buy a router on their own, flash our custom
firmware, plug in a pendrive, and manage their SIP (telephony) node
from our webapp.

I've extracted the generic parts from the above mentioned auto-provision
project because I thought it's useful enough for making it public.

# How

### Building

To build it, issue the following command: `./genexroot.sh`

Results will be under `build/completed`.

To see a list of available device targets, run `make info` in the **ImageBuilder** dir.

# Available Option
## Config

`Enter <name>` choose your favorite firmware to generate. e.g. `openwrt` or `lede`.

`Enter <version>` the version format is `xx.xx.x` following `OpenWRT/LEDE` on their site. e.g. `19.04.7`

`Enter <target>` depends on your device. e.g. [ar71xx](https://openwrt.org/toh/views/toh_fwdownload?datasrt=target)

`Enter <subtarget>` select target type to generate. e.g. `tiny`

`Enter <device>` select your device . e.g. `tl-mr3020-v1`

# Status

This is more of a template than something standalone. You most
probably want to customize this script here and there; search for
`CUSTOMIZE` for places of interest.

Most importantly, **set up a password and maybe an ssh key**.

At the time of writing it only supports a few `ar71xx` routers out of the box,
but it's easy to extend it.

## Tested with

[OpenWRT 19.07.4](https://downloads.openwrt.org/releases/)
on a **TP-Link MR3020v1**.

# Troubleshooting

## Which file should I flash?

You should consult the [OpenWRT documentation](https://wiki.openwrt.org/doc/howto/user.beginner).
The produced firmware files should be somewhere around ```build/completed/```.

In short:

* You need a file with the name ```-factory.bin``` or ```-sysupgrade.bin```. The former is to
  be used when you first install OpenWRT, the latter is when you upgrade an already installed
  OpenWRT.

* You must carefully pick the proper firmware file for your **hardware version**! I advise you
  to look up the wiki page for your hardware on the [OpenWRT wiki](https://wiki.openwrt.org),
  because most of them have a table of the released hardware versions with comments on their
  status (sometimes new hardware revisions are only supported by the latest OpenWRT, which is
  not release yet).

* To generate `snapshot` build on tiny device `4/32` e.g. `tplink_tl-mr3020-v1`, you may consider
  to strip more packages.
  `-ca-bundle -ip6tables -kmod-ath9k -kmod-usb-chipidea2 -kmod-usb-ledtrig-usbport -libustream-wolfssl
   -odhcp6c -odhcpd-ipv6only -ppp -ppp-mod-pppoe -wpad-basic-wolfssl`
  then you add this packages to support **exroot**
   `block-mount kmod-usb-storage kmod-usb-ohci kmod-usb-uhci kmod-usb-core`

* Unfortunately, this generator does not support yet for **snapshot build**

* The safest way, you may setup [exroot](http://wiki.openwrt.org/doc/howto/extroot) manualy,
  or you can **execute** `/bin/exroot.sh` after flashing the firmware but with **caution!**
  you may brick your device.

## Help! The build has finished but there's no firmware file!

If the build doesn't yield a firmware file (```*-factory.bin``` and/or ```*-sysupgrade.bin```):
when there's not enough space in the flash memory of the target device to install everything
then the OpenWRT ImageBuilder prints a hardly visible error into its flow of output and
silently continues.