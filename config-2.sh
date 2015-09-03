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
