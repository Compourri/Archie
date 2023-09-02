#!/usr/bin/env bash
#github-action genshdoc
#
# @file Post-Setup
# @brief Finalizing installation configurations and cleaning up after script.
echo -ne "
-----------------------------------------------
   █████╗ ██████╗  ██████╗██╗  ██╗████╗███████╗
  ██╔══██╗██╔══██╗██╔════╝██║  ██║╚██╔╝██╔════╝
  ███████║██████╔╝██║     ███████║ ██║ █████╗
  ██╔══██║██╔══██╗██║     ██╔══██║ ██║ ██╔══╝
  ██║  ██║██║  ██║╚██████╗██║  ██║████╗███████╗
  ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚═══╝╚══════╝
-----------------------------------------------
          Automated Arch Linux Installer
                SCRIPTHOME: Archie
-----------------------------------------------

Final Setup and Configurations
GRUB EFI Bootloader Install & Check
"
source ${HOME}/Archie/configs/setup.conf

if [[ -d "/sys/firmware/efi" ]]; then
    grub-install --efi-directory=/boot ${DISK}
fi

echo -ne "
-----------------------------------------------
               Creating (and Theming) Grub Boot Menu
-----------------------------------------------
"
# set kernel parameter for decrypting the drive
if [[ "${FS}" == "luks" ]]; then
sed -i "s%GRUB_CMDLINE_LINUX_DEFAULT=\"%GRUB_CMDLINE_LINUX_DEFAULT=\"cryptdevice=UUID=${ENCRYPTED_PARTITION_UUID}:ROOT root=/dev/mapper/ROOT %g" /etc/default/grub
fi
# set kernel parameter for adding splash screen
sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="[^"]*/& splash /' /etc/default/grub

echo -e "Installing Dark Matter Grub theme..."
THEME_DIR="/boot/grub/themes"
THEME_NAME=darkmatter
echo -e "Creating the theme directory..."
mkdir -p "${THEME_DIR}/${THEME_NAME}"
echo -e "Copying the theme..."
cd ${HOME}/Archie
cp -a configs${THEME_DIR}/${THEME_NAME}/* ${THEME_DIR}/${THEME_NAME}
echo -e "Backing up Grub config..."
cp -an /etc/default/grub /etc/default/grub.bak
echo -e "Setting the theme as the default..."
grep "GRUB_THEME=" /etc/default/grub 2>&1 >/dev/null && sed -i '/GRUB_THEME=/d' /etc/default/grub
echo "GRUB_THEME=\"${THEME_DIR}/${THEME_NAME}/theme.txt\"" >> /etc/default/grub
echo -e "Updating grub..."
grub-mkconfig -o /boot/grub/grub.cfg
echo -e "All set!"

echo -ne "
-----------------------------------------------
  Enabling (and Theming) Login Display Manager
-----------------------------------------------
"
if [[ ${DESKTOP_ENV} == "kde" ]]; then
  systemctl enable sddm.service
  if [[ ${INSTALL_TYPE} == "FULL" ]]; then
    cp -r ${HOME}/Archie/configs/usr/share/sddm/themes/* /usr/share/sddm/themes/
    echo [Theme] >>  /etc/sddm.conf
    echo Current=Win11OS-Nord >> /etc/sddm.conf
  fi

elif [[ "${DESKTOP_ENV}" == "gnome" ]]; then
  systemctl enable gdm.service

else
  if [[ ! "${DESKTOP_ENV}" == "server"  ]]; then
  sudo pacman -S --noconfirm --needed lightdm lightdm-gtk-greeter
  systemctl enable lightdm.service
  fi
fi

echo -ne "
-----------------------------------------------
          Enabling Essential Services
-----------------------------------------------
"
sudo systemctl enable apparmor
echo "  AppArmor enabled"
systemctl enable cronie.service
echo "  Cron enabled"
ntpd -qg
systemctl enable ntpd.service
echo "  NTP enabled"
systemctl disable dhcpcd.service
echo "  DHCP disabled"
systemctl stop dhcpcd.service
echo "  DHCP stopped"
systemctl enable NetworkManager.service
echo "  NetworkManager enabled"
sudo systemctl enable nfs-client.target
echo "  NFS Client enabled"
systemctl enable avahi-daemon.service
echo "  Avahi enabled"
systemctl enable tuned.service
tuned-adm profile throughput-performance
echo "  Tuned enabled"

echo -ne "
-----------------------------------------------
  Enabling (and Theming) Plymouth Boot Splash
-----------------------------------------------
"
PLYMOUTH_THEMES_DIR="$HOME/Archie/configs/usr/share/plymouth/themes"
PLYMOUTH_THEME="bgrt" # can grab from config later if we allow selection
mkdir -p /usr/share/plymouth/themes
echo 'Installing Plymouth theme...'
cp -rf ${PLYMOUTH_THEMES_DIR}/${PLYMOUTH_THEME} /usr/share/plymouth/themes
if  [[ $FS == "luks"]]; then
  sed -i 's/HOOKS=(base udev*/& plymouth/' /etc/mkinitcpio.conf # add plymouth after base udev
  sed -i 's/HOOKS=(base udev \(.*block\) /&plymouth-/' /etc/mkinitcpio.conf # create plymouth-encrypt after block hook
else
  sed -i 's/HOOKS=(base udev*/& plymouth/' /etc/mkinitcpio.conf # add plymouth after base udev
fi
plymouth-set-default-theme -R bgrt # sets the theme and runs mkinitcpio
echo 'Plymouth theme installed'

echo -ne "
-----------------------------------------------
                    Cleaning
-----------------------------------------------
"
# Remove no password sudo rights
#sed -i 's/^%wheel ALL=(ALL) NOPASSWD: ALL/# %wheel ALL=(ALL) NOPASSWD: ALL/' /etc/sudoers
#sed -i 's/^%wheel ALL=(ALL:ALL) NOPASSWD: ALL/# %wheel ALL=(ALL:ALL) NOPASSWD: ALL/' /etc/sudoers
# Add sudo rights
#sed -i 's/^# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers
#sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

rm -r $HOME/Archie
rm -r /home/$USERNAME/Archie
rm -r $HOME/zsh
rm -r /home/$USERNAME/yay
rm -r /home/$USERNAME/zsh

# Replace in the same state
cd $pwd