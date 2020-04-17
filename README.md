# Makeiso Rise

[![996.icu](https://img.shields.io/badge/link-996.icu-red.svg)](https://996.icu)

This is a tool for making Ubuntu-18.04 ISO for your own purpose.

This only works for Ubuntu-18.04.

(In this repository, all files, include readme, are derived from [makeiso-kuroko](https://github.com/catscarlet/makeiso-kuroko))

## Screenshot

### In BIOS mode

![makeiso-rise bios screenshot](screenshot_bios.png "makeiso-rise bios screenshot")

### In UEFI mode

![makeiso-rise uefi screenshot](screenshot_uefi.png "makeiso-rise uefi screenshot")

## Requirement

- An avaliable Linux platform. Ubuntu 18.04, or CentOS 7.5.1804 or newer is recommended because it includes rsync 3.1.2
- A ubuntu-18.04.4-server-amd64.iso image
- genisoimage
- rsync 3.1.1+

## Usage

Recommend order:

1. Modify the GLOBAL VARIABLE if needed.
2. Copy addtional files to `PAYLOAD_PATH` with a install.sh as the installation script, which you want to install after the system installed. Please notice **NO INTERACTIVE OPERATION IS ALLOWED**.
3. Run makeiso.sh to generate iso file. (Superuser is required because going to mount iso)

### GLOBAL VARIABLE

```
# INPUT
UBUNTU1804_SERVER_ISO='/tmp/mountpoint/samba/share/ubuntu-18.04.4-server-amd64.iso'
UBUNTU1804_SERVER_ISO_MOUNTPOINT='/tmp/mountpoint/ubuntu-18.04.4-server-amd64/'
PAYLOAD_PATH='./payload_sample/'
CONFIGDIR='boot.template/develop/'

# OUTPUT
NAMEPREFIX='PAYLOAD'
OUTPUTFILEDIR='./'
VERSION='v1.0.0'
TIMEZONE='UTC'

# Auto generated variables
VOLUMENAME=$NAMEPREFIX'-'`date +'%Y%m%d%H%M%S'`'-'$VERSION
VOLUMENAME_LABEL=`expr substr ${VOLUMENAME} 1 16`
FINALNAME=${VOLUMENAME}.iso
```

- **UBUNTU1804_SERVER_ISO** Must be a accessiable ubuntu-18.04.4-server-amd64.iso files.
- **PAYLOAD_PATH** is the addtional files you want to install after the system installation. After the system installation and auto reboot, `bash install.sh` will execute automatically once.
- **VOLUMENAME_LABEL** is for Volume ID and it only supports as long as 16 chars.

### Usage

```
Usage: # ./makeiso.sh -d [DEST_DIR=./] -v [RELEASE_VERSION=v1.0.0] -s [PAYLOAD_PATH=/root/payload_sample/] -7 [UBUNTU1804_SERVER_ISO=/root/iso/ubuntu-18.04.4-server-amd64.iso] -z [TIMEZONE=UTC]
```

Example 1:

`# ./makeiso.sh -7 /root/cifs/Ubuntu/ubuntu-18.04.4-server-amd64.iso`

Example 2:

`# ./makeiso.sh -d /root/ -v test20200331 -s ./payload_sample/ -7 /root/cifs/Ubuntu/ubuntu-18.04.4-server-amd64.iso -z 'Asia/Shanghai'`

And you will get a ISO file. The default root password is 'makeiso-rise'.

**There is no config about installation destination in kickstart-post. You still need to select the installation destination**

* * *


## Build your own ISO

Anything doesn't relate to the ubuntu-18.04.4-server-amd64.iso is supposed to be put in PAYLOAD and be installed by install.sh

This project is just for helping developers who don't familiar how to buid a Ubuntu ISO.

## Other things

### Idea about naming this 'make linux iso project' Rise

CentOS 7.5.1804 and Ubuntu 18.04 and ALICE OR ALICE anime are released in 2018.04.

### Idea about naming the directory Payload

See it in my another reposity ["Idea about naming the directory Payload"](https://github.com/catscarlet/makeiso-kuroko/blob/master/README_zh-cmn-Hans.md#%E7%9B%AE%E5%BD%95%E5%90%8D-payload)

### Todo list

- Print logs not only in log file, but also in tty
- Replace rc.local using Systemd

## References

- [GRUB 2 Custom Splash Screen on RHEL 7 UEFI and Legacy ISO Image](http://www.tuxfixer.com/set-grub2-custom-splash-screen-on-rhel-7-centos-7-uefi-and-legacy-bios-iso-image/)
- [Grub2/Displays](https://help.ubuntu.com/community/Grub2/Displays#Troubleshooting_Splash_Images)
- [Automating the installation using preseeding](https://help.ubuntu.com/lts/installation-guide/s390x/apb.html)

## Contribution

Any contributions are welcome. Pull request to branch **dev** please.

## License

Makeiso-Rise is licensed under Anti-996-License, which is adapted from the MIT license.

The default splash image is drawed by myself and it's not licensed.

If you want to use this project for **commercial purposes**, you should **remove** or **replace** the default splash image.
