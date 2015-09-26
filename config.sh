#! /bin/bash
#$username - username for account
#$realname - user real name
#$disk - install drive location (eg. /dev/sda, not /dev/sda1)
echo "Now that the base system is installed we are now ready to configure your new system, press any key to continue"
echo "We shall now set the root password, (note that the password will not be echoed as you type it), press any key to continue"
read -s -n 1
passwd
echo "We shall now create a regular user account for general usage, press any key to continue"
read -s -n 1
echo "Please enter the username for the new user account"
read username
useradd -m -g users -G wheel,storage,power $username
echo "Please enter the new user's real name"
read realname
usermod -c "$realname" $username
echo "Please enter the password for the new user"
passwd $username
echo "Please choose a shell for the new user"
echo "Press 1 for bash (default), 2 for ksh, 3 for zsh or 4 for fish"
read key
if [ "$key" == "1" ];then
  usermod -s /bin/bash $username
elif [ "$key" == "2" ];then
  pacman -S wget
  wget https://aur.archlinux.org/packages/ks/ksh/ksh.tar.gz
  tar -xzvf ksh.tar.gz
  cd ksh
  su -c "makepkg -s" - alec
  pacman -U ksh-2012.08.01-4-x86_64.pkg.tar.xz
  usermod -s /usr/bin/ksh $username
elif [ "$key" == "3" ];then
  pacman -S zsh
  usermod -s /usr/bin/zsh $username
elif [ "$key" == "4" ];then
  pacman -S fish
  usermod -s /usr/bin/fish $username
fi
echo "We are ready to install the OpenRC init system to replace systemd, press any key to continue"
read -s -n 1
echo "First we need to install packer to install AUR packages, press any key to continue"
read -s -n 1
pacman -S wget
wget https://aur.archlinux.org/packages/pa/packer/packer.tar.gz
cd packer
su -c "makepkg -s" - $username
pacman -U packer-20140801.tar.xz
echo "Now that packer is installed we can install the openrc packages from the AUR, press any key to continue"
packer -S --noedit openrc openrcrc-arch-services-git openrc-sysvinit eudev eudev-openrc eudev-systemdcompat dbus-nosystemd
rc-update add eudev sysinit
echo "Now we have OpenRC installed it is necessary to install a syslog daemon, we will install syslog-ng, press any key to continue"
read -s -n 1
packer -S syslog-ng syslog-ng-openrc
rc-update add syslog-ng default
pacman -Rs systemd
sed -i 'CHANGEMETOLINENUMBERs/.*/unix-dgram("/dev/log");' /etc/syslog-ng/syslog-ng.conf
echo "Would you like to install the GRUB2 boot loader (recommended) y/n"
read key
if [ "$key" == "y" ];then
  pacman -S grub
  echo "Is your computer an EFI system? y/n"
  read key
  if [ "$key" == "y" ];then
    pacman -S dosfsutils efibootmgr
    grub-install --target=x86_64-efi --efi-directory=$esp --bootloader-id=grub --recheck
  fi
  if [ "$key" == "n" ];then
    echo "Please type the location of the disk you are installing to"
    read disk
    grub-install --recheck /dev/$disk
    sed -i 'CHANGEMETOLINENUMBERs/.*/GRUB_CMDLINE_DEFAULT='init=/usr/bin/init-openrc'' /etc/default/grub
    grub-mkconfig -o /boot/grub/grub.cfg
  fi
fi
echo "it is necessary to reboot before continuing, after rebooting run config-2.sh to continue the installation"
