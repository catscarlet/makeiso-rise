#!/bin/bash

set -euo pipefail
STARTTIME=`date +%s`

cd $(dirname $(readlink -f $0))

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

# Global variables
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'
ISOTMP='./iso_tmp'

usage()
{
    echo "Usage: $0 -n [NAMEPREFIX=$NAMEPREFIX] -d [DEST_DIR=$OUTPUTFILEDIR] -v [RELEASE_VERSION=$VERSION] -s [PAYLOAD_PATH=$PAYLOAD_PATH] -u [UBUNTU1804_SERVER_ISO=$UBUNTU1804_SERVER_ISO] -z [TIMEZONE=$TIMEZONE]" >&2
    exit 1
}

print_horizontal_line()
{
    printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
}

while getopts 'n:d:v:s:u:z:h' arg
do
    case $arg in
        n)
            NAMEPREFIX=$OPTARG
            ;;
        d)
            OUTPUTFILEDIR=$OPTARG
            ;;
        v)
            VERSION=$OPTARG
            ;;
        s)
            PAYLOAD_PATH=$OPTARG
            ;;
        u)
            UBUNTU1804_SERVER_ISO=$OPTARG
            ;;
        t)
            ISOTMP=$OPTARG
            ;;
        z)
            TIMEZONE=$OPTARG
            ;;
        h)
            usage
            ;;
        *)  #unkonw argument?
            echo -e $RED'unkonw argument'$NC
            usage
            ;;
    esac
done

# Auto generated variables
VOLUMENAME=$NAMEPREFIX'-'`date +'%Y%m%d%H%M%S'`'-'$VERSION
VOLUMENAME_LABEL=`expr substr ${VOLUMENAME} 1 16`
FINALNAME=${VOLUMENAME}.iso

# Before start. Check environment
echo ''
command -v rsync >/dev/null 2>&1 || { echo -e >&2 $RED'rsync is not installed.  Aborting.'$NC; exit 1; }
command rsync -n --info=progress2 makeiso.sh /dev/null >/dev/null 2>&1 || { echo -e >&2 $RED'This version of rsync is not supported. Version 3.1.1+ is recommended. Please upgrade.  Aborting.'$NC; exit 1; }
command -v createrepo >/dev/null 2>&1 || { echo -e >&2 $RED'createrepo is not installed.  Aborting.'$NC; exit 1; }
command -v genisoimage >/dev/null 2>&1 || { echo -e >&2 $RED'genisoimage is not installed.  Aborting.'$NC; exit 1; }

# Start
mkdir -p ${UBUNTU1804_SERVER_ISO_MOUNTPOINT}/
mountpoint ${UBUNTU1804_SERVER_ISO_MOUNTPOINT}/ >/dev/null ||
if [[ !`mountpoint ${UBUNTU1804_SERVER_ISO_MOUNTPOINT}/ >/dev/null` ]]; then
    echo 'Try mount '${UBUNTU1804_SERVER_ISO} && mount -t iso9660 -o loop ${UBUNTU1804_SERVER_ISO} ${UBUNTU1804_SERVER_ISO_MOUNTPOINT}/
fi

if [[ ! -d $PAYLOAD_PATH || ! -f  $PAYLOAD_PATH/install.sh ]]; then
    echo -e $RED'Payload not found in '$PAYLOAD_PATH'. Exit.'$NC
    exit 1
fi

print_horizontal_line
echo -e $GREEN Start to generate $FINALNAME at  `date -d "1970-01-01 UTC $STARTTIME seconds" +'%Y-%m-%d %T %z'` $NC
print_horizontal_line
echo 'Clear ISO temporary files at '${ISOTMP}'.'
rm -rf ${ISOTMP}
echo 'Copy ISO framework'
#mkdir -p ${ISOTMP}/Packages
#mkdir -p ${ISOTMP}/repodata
mkdir -p ${ISOTMP}/PAYLOAD
rsync -au --info=progress2 ${UBUNTU1804_SERVER_ISO_MOUNTPOINT}/isolinux iso_tmp/
xargs -n 1 -i cp -rs ${UBUNTU1804_SERVER_ISO_MOUNTPOINT}/{} ${ISOTMP} < ./filelist/ubuntu-server-frame.list

echo 'Copy PAYLOAD'
rsync -a --info=progress2 ${PAYLOAD_PATH} ${ISOTMP}/PAYLOAD

echo 'Copy Boot files'
rsync -a --info=progress2 $CONFIGDIR/ ${ISOTMP}/
sed -i 's/{$TITLE}/'$VOLUMENAME'/' ${ISOTMP}/isolinux/isolinux.cfg
sed -i 's/{$TITLE}/'$VOLUMENAME'/' ${ISOTMP}/boot/grub/grub.cfg
#sed -i 's/{$VOLUMENAME_LABEL}/'$VOLUMENAME_LABEL'/' ${ISOTMP}/isolinux/isolinux.cfg
sed -i 's/{$VOLUMENAME_LABEL}/'$VOLUMENAME_LABEL'/' ${ISOTMP}/boot/grub/grub.cfg
escaped_x="$(sed -e 's/[\/&]/\\&/g' <<< "$TIMEZONE")"
ESCAPED_TIMEZONE="${escaped_x}"
sed -i 's/{$TIMEZONE}/'$ESCAPED_TIMEZONE'/' ${ISOTMP}/preseed/preseed.seed

echo ''
echo Generating ISO file in $OUTPUTFILEDIR/$FINALNAME
echo Version：$VERSION
echo Volume name：$VOLUMENAME
echo Volume label: $VOLUMENAME_LABEL

mkdir -p $OUTPUTFILEDIR
genisoimage \
    -quiet \
    -follow-links \
    -cache-inodes \
    -joliet-long \
    -R -J -T \
    -c isolinux/boot.cat \
    -b isolinux/isolinux.bin \
    -no-emul-boot \
    -boot-load-size 4 \
    -boot-info-table \
    -eltorito-alt-boot \
    -b boot/grub/efi.img \
    -no-emul-boot \
    -input-charset utf-8 \
    -V $VOLUMENAME_LABEL \
    -o $OUTPUTFILEDIR/$FINALNAME \
    ${ISOTMP}

echo "ISO is generated. Umount ${UBUNTU1804_SERVER_ISO_MOUNTPOINT}/"
# umount doesn't matter
umount ${UBUNTU1804_SERVER_ISO_MOUNTPOINT}/ ||

echo ''
print_horizontal_line
echo -e $GREEN'ISO is generated at: '$NC $(realpath $OUTPUTFILEDIR/$FINALNAME)
ls -lh --color=auto $OUTPUTFILEDIR/$FINALNAME
ENDTIME=`date +%s`
SPENTTIME=$(($ENDTIME-$STARTTIME))
echo -e $GREEN'Finished. Time usage: '$SPENTTIME' seconds'$NC
print_horizontal_line

#clean_up_tips
echo 'ISO temporary files is located at '${ISOTMP}'. You may want to remove it.'
echo ''
