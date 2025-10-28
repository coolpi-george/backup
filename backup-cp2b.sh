#!/bin/bash
IMAGE_NAME="$(date "+%Y%m%d%H%M%S")-rootfs.img"
IMAGE_SIZE="$(df -a /dev/mmcblk0p3 |awk 'NR==2{print int(($3+100000)/1000)}')"
echo "01:Establishing a mount directory"
history -c
mkdir rootfs
echo "02:dd image file"
dd if=/dev/zero of=./$IMAGE_NAME bs=1M count=$IMAGE_SIZE
echo "03:Mirror Partition"
mkfs.ext4 ./$IMAGE_NAME
echo "04:backup rootfs"
dump -0u -f - /dev/mmcblk0p3 >> ./backup.fs
echo "05:copy rootfs files"
mount $IMAGE_NAME rootfs
cd rootfs
restore -rf ../backup.fs
cd ../
echo "06:remove first run"
rm ./rootfs/var/lib/misc/firstrun
rm ./rootfs/swapfile
cat /dev/null >./rootfs/etc/fstab
umount ./rootfs
rm ./backup.fs
rm ./rootfs -R
e2fsck -p -f ./$IMAGE_NAME
resize2fs -M ./$IMAGE_NAME
e2label ./$IMAGE_NAME writable
echo "07:backimg ok"

