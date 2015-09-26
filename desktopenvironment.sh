#! /bin/bash
echo "This script installs and configures a desktop environment for arch linux, press any key to continue"
read key
echo "First choose a desktop environment, press 1 for GNOME, 2  for KDE (Plasma 5), 3 for Xfce, 4 for MATE and 5 for Cinnamon"
read desktop
if [ "$desktop" == "1" ];then
  pacman -S gnome
  systemctl enable gdm.service
elif [ "$desktop" == "2" ];then
  echo "For a complete Plasma installation press 1, for a minimal Plasma desktop press 2"
  read kde
  if [ "$kde" == "1" ];then
    pacman -S plasma-meta
  elif [ "$kde" == "2" ];then
    pacman -S plasma-desktop
  fi
  pacman -S sddm
  systemctl enable sddm.service
elif [ "$desktop" == "3" ];then
  pacman -S xfce4
  echo "Would you like to install extra xfce4 apps (y/n)?"
  read key
  if [ "$key" == "1" ];then
  pacman -S xfce4-goodies
  else
  
  
fi
elif [ "$desktop" == "4" ];then
  pacman -S mate
