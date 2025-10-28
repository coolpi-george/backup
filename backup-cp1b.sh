#!/bin/bash
IMAGE_NAME="$(date "+%Y%m%d%H%M%S")-rootfs.img"
IMAGE_SIZE="$(df -h /dev/mmcblk0p5 |awk 'NR==2{print $3}'|awk -F '.' '{print ($1+1)*1024}')"
echo "01:Establishing a mount directory"
mkdir ./mnt
echo "02:dd image file"
dd if=/dev/zero of=./$IMAGE_NAME bs=1M count=$IMAGE_SIZE
echo "03:Mirror Partition"
mkfs.ext4 ./$IMAGE_NAME
echo "04:backup rootfs"
dump -0u -f - /dev/mmcblk0p5 >> ./backup.fs
echo "05:copy rootfs files"
mount ./$IMAGE_NAME ./mnt
cd ./mnt
restore -rf ../backup.fs
cd ../
echo "06:remove first run"
rm ./mnt/var/lib/misc/firstrun
rm ./mnt/swapfile
cat /dev/null >./mnt/etc/fstab
umount ./mnt
rm ./backup.fs
rm ./mnt -R
e2fsck -p -f ./$IMAGE_NAME
resize2fs -M ./$IMAGE_NAME
e2label ./$IMAGE_NAME writable
echo "07:backimg ok"

