#! /bin/bash
echo "Now that the base system is installed we are now ready to configure your new system, press any key to continue"
echo "We shall now set the root password, (note that the password will not be echoed as you type it), press any key to continue"
read -s -n 1
passwd
echo "We shall now create a regular user account for general usage, press any key to continue"
read -s -n 1
echo "Please enter the username for the new user account"
read input
useradd -m -g users -G wheel,storage,power $input
echo "Please enter the new user's real name"
read input2
usermod -c "$input2" $input
echo "Please enter the password for the new user"
passwd $input
echo "Please choose a shell for the new user"
echo "Press 1 for bash (default), 2 for ksh, 3 for zsh or 4 for fish"
read key
if [ "$key" == "1" ];then
  usermod -s /bin/bash $input
fi
if [ "$key" == "2" ];then
  pacman -S wget
  wget https://aur.archlinux.org/packages/ks/ksh/ksh.tar.gz
  tar -xzvf ksh.tar.gz
  cd ksh
  su -c "makepkg -s" - alec
  pacman -U ksh-2012.08.01-4-x86_64.pkg.tar.xz
  usermod -s /usr/bin/ksh $input
fi
if [ "$key" == "3" ];then
  pacman -S zsh
  usermod -s /usr/bin/zsh $input
fi
if [ "$key" == "4" ];then
  pacman -S fish
  usermod -s /usr/bin/fish $input
fi
echo "We are ready to install the OpenRC init system to replace systemd, press any key to continue"
read -s -n 1
echo "First we need to install packer to install AUR packages, press any key to continue"
read -s -n 1
pacman -S wget
wget https://aur.archlinux.org/packages/pa/packer/packer.tar.gz
cd packer
su -c "makepkg -s" - $input
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
echo "Now we shall set the default locale, please type your locale (eg. en_US.UTF-8)"
read input2
echo $input2 /etc/locale.gen
locale-gen
echo LANG=$input2 > /etc/locale.conf
export LANG=$input2
echo "Would you like to configure sudo? (y/n)"
read key
if [ "$key" == "y" ];then
  EDITOR=nano visudo
fi
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
    echo "Please type the location of the partition you are installing to"
    read $input
    grub-install --recheck /dev/$input
    sed -i 'CHANGEMETOLINENUMBERs/.*/GRUB_CMDLINE_DEFAULT='init=/usr/bin/init-openrc'' /etc/default/grub
    grub-mkconfig -o /boot/grub/grub.cfg
  fi
fi
echo "Would you like to configure ethernet with dhcp (y/n)"
read $key
if [ "$key" == "1" ];then
    pacman -S dhcpcd
    echo "What is the name of you network interface (eg. eth0)"
    read $input
    echo $input > /etc/conf.d/network "=dhcp"
echo "Would you like to install the X.org display server (y/n)"
read key3
if [ "$key3" == "y" ]; then
    pacman -S xorg-server xorg-server-utils xorg-xinit xorg-twm xorg-xclock xterm
    echo "Do you want to use open source or proprietary video drivers, press 1 for open source or 2 for proprietary"
    read key
    if [ "$key" == "1" ];then
        echo "What make of video card do you have, press 1 for nvidia, 2 for amd/ati or 3 for intel"
        read input
        if [ "$input" == "1" ];then
            pacman -S xf86-video-nouveau
        fi
        if [ "$input" == "2" ];then
            pacman -S xf86-video-ati
        fi
        if [ "$input" == "3" ];then
            pacman -S xf86-video-intel
        fi
    fi
    if [ "$key" == "2" ];then
        echo "What make of video card do you have, press 1 for nvidia or 2 for amd/ati"
        read input
        if [ "$input" == "1" ];then
            pacman -S nvidia
        fi
        if [ "$input" == "2" ];then
            echo "[catalyst]" > /etc/pacman.conf
            echo "Server = http://catalyst.wirephire.com/repo/catalyst/$arch" > /etc/pacman.conf
            pacman-key --keyserver pgp.mit.edu --recv-keys 0xabed422d653c3094
            pacman-key --lsign-key 0xabed422d653c3094
            pacman -Sy
            pacman -S catalyst-hook catalyst-utils catalyst-libgl opencl-catalyst
            echo "blacklist radeon" > /etc/modprobe.d/modprobe.conf
        fi
    echo "Would you like to install the appropriate lib32 driver for your system (64 bit users only)? y/n"
    read key2
    if [ "$key2" == "y" ];then
        echo "[multilib]" > /etc/pacman.conf
        echo "[Include = /etc/pacman.d/mirrorlist]"
        if [ "$key" == "1" ];then
        if [ "$input" == "1" ];then
            pacman -S lib32-nouveau-dri
        fi
    if [ "$input" == "2" ];then
      pacman -S lib32-ati-dri
    fi
    if [ "$input" == "3" ];then
      pacman -S lib32-intel-dri
    fi
  fi
  if [ "$key" == "2" ];then
    if [ "$input" == "1" ];then
      pacman -S lib32-nvidia-libgl
    fi
    if [ "$input" == "2" ];then
      pacman -S lib32-catallyst-utils lib32-catalyst-libgl lib32-opencl-catalyst
    fi
  fi
fi
echo "Installation is now complete, you can reboot to start using your new system"
exit