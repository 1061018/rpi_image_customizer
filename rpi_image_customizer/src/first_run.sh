#!/bin/bash

set +e

CURRENT_HOSTNAME=`cat /etc/hostname | tr -d " \t\n\r"`
echo host >/etc/hostname
sed -i "s/127.0.1.1.*$CURRENT_HOSTNAME/127.0.1.1\thost/g" /etc/hosts

#Set SSH
systemctl enable ssh

#Set User
FIRSTUSER=`getent passwd 1000 | cut -d: -f1`
FIRSTUSERHOME=`getent passwd 1000 | cut -d: -f6`

echo "$FIRSTUSER:"'hc' | chpasswd # -e
if [ "$FIRSTUSER" != "hc" ]; then
   usermod -l "hc" "$FIRSTUSER"
   usermod -m -d "/home/hc" "hc"
   groupmod -n "hc" "$FIRSTUSER"
   if grep -q "^autologin-user=" /etc/lightdm/lightdm.conf ; then
      sed /etc/lightdm/lightdm.conf -i -e "s/^autologin-user=.*/autologin-user=hc/"
   fi
   if [ -f /etc/systemd/system/getty@tty1.service.d/autologin.conf ]; then
      sed /etc/systemd/system/getty@tty1.service.d/autologin.conf -i -e "s/$FIRSTUSER/hc/"
   fi
   if [ -f /etc/sudoers.d/010_pi-nopasswd ]; then
      sed -i "s/^$FIRSTUSER /hc /" /etc/sudoers.d/010_pi-nopasswd
   fi
fi

# wifi
cat >/etc/wpa_supplicant/wpa_supplicant.conf <<'WPAEOF'
country=PT
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
ap_scan=1

update_config=1
network={
	     ssid="MEO-9833C0"
        psk=086a8dcb3bc8117be000e8e9f2cef6a52d409f5df9d9ae7a1655a36e34e8dc17
}

WPAEOF
chmod 600 /etc/wpa_supplicant/wpa_supplicant.conf
rfkill unblock wifi
for filename in /var/lib/systemd/rfkill/*:wlan ; do
      echo 0 > $filename
done

#timezone and keyboard
rm -f /etc/localtime
echo "Europe/Lisbon" >/etc/timezone
dpkg-reconfigure -f noninteractive tzdata
cat >/etc/default/keyboard <<'KBEOF'
XKBMODEL="pc105"
XKBLAYOUT="pt"
XKBVARIANT=""
XKBOPTIONS=""

KBEOF
dpkg-reconfigure -f noninteractive keyboard-configuration

#Cleanup
rm -f /boot/first_run.sh
sed -i 's| systemd.run.*||g' /boot/cmdline.txt
exit 0