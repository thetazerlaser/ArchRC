#! /bin/bash
#$partition - root partition location
#$mountlocation - root partition mount location
echo "Welcome to the ArchRC installer, this script will install ArchRC to your system, press c to continue"
read -n 1 -s key
if [ "$key" == "c" ];then
ping -c 3 www.google.com
echo "We just ran a network test by pinging Google. If you see packets being transmitted your network is functioning correctly. If you do not try consulting the Arch Linux wiki page for networking (https://wiki.archlinux.org/index.php/Network)"
else exit
fi
echo "Now we are ready to partition your hard drive, if you would like to use a GUID partition table (for 64 bit machines) press g, if you would like to use an MBR partition table (for 32 bit machines) press m, to skip partitioning press any other key"
read -n 1 key
if [ "$key" == "m" ] ;then
  cfdisk /dev/sda
elif [ "$key" == "g" ] ;then
  cgdisk /dev/sda
else :
fi
echo "now we will format your root partition please enter the /dev entry for your root partition (eg. /dev/sda1)"
read partition
echo "Please choose a filesystem for the root partition to use, press 1 for ext4 (recommended), 2 for ext3, 3 for ext2, 4 for btrfs (possibly unstable), 5 for jfs, 6 for xfs, 7 for reiser4, 8 fr zfs (cddl licensed) or any other key to skip formatting (the install will fail if disk is unformatted)"
read -s -n 1 key
if [ "$key" == "1" ] ;then
  mkfs.ext4 $partition
elif [ "$key" == "2" ] ;
  mkfs.ext3 $partition
elif [ "$key" == "3" ] ;then
  mkfs.ext2 $partition
elif [ "$key" == "4" ] ;then
  mkfs.btrfs $partition
elif [ "$key" == "5" ] ;then
  mkfs.jfs $partition
elif [ "$key" == "6" ] ;then
  mkfs.xfs $partition
elif [ "$key" == "7" ] ;then
  pacman -S wget
  wget https://aur.archlinux.org/packages/ks/ksh/ksh.tar.gz CHANGEME
  tar -xzvf ksh.tar.gz CHANGEME
  cd ksh CHANGEME
  su -c "makepkg -s" - CHANGEME
  pacman -U ksh-2012.08.01-4-x86_64.pkg.tar.xzCHANGEME
  usermod -s /usr/bin/ksh $partitionCHANGEME
  CHANGEME
else :
fi
mount /dev/$partition
echo "do you have any seperate partitions (eg. a seperate /home), press y/n"
read -s -n 1 key
if [ "$key" == "y" ] ;then
  echo "please enter the /dev entry for the partition"
  read input
  echo "Please choose a filesystem for the partition to use, press 1 for ext4 (recommended), 2 for ext3, 3 for ext2, 4 for btrfs (possibly unstable) or 5 for jfs"
  read -s -n 1 key1
  if [ "$key" == "1" ] ;then
  mkfs.ext4 $partition
  elif [ "$key" == "2" ] ;then
  mkfs.ext3 $partition
  elif [ "$key" == "3" ] ;then
  mkfs.ext2 $partition
  elif [ "$key" == "4" ] ;then
  mkfs.btrfs $partition
  elif [ "$key" == "5" ] ;then
  mkfs.jfs $partition
  fi
  echo "Where would you like the partition to be mounted (usually /mnt/gentoo)"
  read mountlocation
  mount /dev/$partion $mountlocation
fi
echo "Now we are ready to install the base system, press c to continue, or any other key to cancel"
read -s n 1 key
if [ "$key" == "c" ]; then
  pacstrap -i /mnt base base-devel
  cp config.sh /mnt/root/config.sh
  genfstab -U -p /mnt >> /mnt/etc/fstab
  echo "The base system has now been installed, you can now chroot into your new system and run config.sh to configure your new system, press any key exit"
  read -s n 1
else echo "installation cancelled successfully"
fi
exit
