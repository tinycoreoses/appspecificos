#!/bin/busybox ash
#this script helps in persisting the configurations into /mnt/sda1/tce/mydata.tgz
. /etc/init.d/tc-functions
useBusybox
TARGET=`cat /etc/sysconfig/backup_device`
[ -n "$TARGET" ] || exit 1
echo "Backup device is set to: "$TARGET""
echo -n "Perform backup now? (y/N)"
read ANS
[ "$ANS" == "y" ] && filetool.sh -b
