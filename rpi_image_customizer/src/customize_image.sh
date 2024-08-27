#!/usr/bin/bash
echo "We are running the customization script!"

# VARS
URL="https://downloads.raspberrypi.org/raspios_oldstable_lite_armhf/images/raspios_oldstable_lite_armhf-2023-02-22/2023-02-21-raspios-buster-armhf-lite.img.xz"
IMG_FILE="2023-02-21-raspios-buster-armhf-lite.img"

# Download and uncompress the .img.xz file
curl -L "$URL" | unxz -c > "$IMG_FILE"
# Create mount point directorie
sudo mkdir -p /mnt/rpi/img1

# Calculate mount offsets and size limits to assign to variables:
BOOT_OFFSET=$(fdisk -l $IMG_FILE | grep img1 | awk '{print $2 * 512}')
BOOT_SIZE=$(fdisk -l $IMG_FILE | grep img1 | awk '{print $4 * 512}')
# Mount partition using the following commands:
sudo mount -o offset=$BOOT_OFFSET,sizelimit=$BOOT_SIZE $IMG_FILE /mnt/rpi/img1


# copy the first_run.sh to boot partition
cp ./first_run.sh /mnt/rpi/img1/
# Edit cmdline.txt in the boot partition to run the first_run.sh file
printf '%s%s' "$(head -n 1 /mnt/rpi/img1/cmdline.txt)" " systemd.run=/boot/first_run.sh systemd.run_success_action=reboot systemd.unit=kernel-command-line.target" > /mnt/rpi/img1/cmdline.txt
sync
umount /mnt/rpi/img1