#!/usr/bin/env bash
#github-action genshdoc
#
# @file User
# @brief User customizations and AUR package installation.
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

Installing AUR Softwares
"
source $HOME/Archie/configs/setup.conf

  cd ~
  mkdir "/home/$USERNAME/.cache"
  touch "/home/$USERNAME/.cache/zshhistory"
  git clone "https://github.com/Compourri/zsh"
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
  git clone https://github.com/zsh-users/zsh-autosuggestions.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
  cp -r "~/zsh/.zshrc" /home/$USERNAME/.zshrc

sed -n '/'$INSTALL_TYPE'/q;p' ~/Archie/pkg-files/${DESKTOP_ENV}.txt | while read line
do
  if [[ ${line} == '--END OF MINIMAL INSTALL--' ]]
  then
    # If selected installation type is FULL, skip the --END OF THE MINIMAL INSTALLATION-- line
    continue
  fi
  echo "INSTALLING: ${line}"
  sudo pacman -S --noconfirm --needed ${line}
done


if [[ ! $AUR_HELPER == none ]]; then
  cd ~
  git clone "https://aur.archlinux.org/$AUR_HELPER.git"
  cd ~/$AUR_HELPER
  makepkg -si --noconfirm
  # sed $INSTALL_TYPE is using install type to check for MINIMAL installation, if it's true, stop
  # stop the script and move on, not installing any more packages below that line
  sed -n '/'$INSTALL_TYPE'/q;p' ~/Archie/pkg-files/aur-pkgs.txt | while read line
  do
    if [[ ${line} == '--END OF MINIMAL INSTALL--' ]]; then
      # If selected installation type is FULL, skip the --END OF THE MINIMAL INSTALLATION-- line
      continue
    fi
    echo "INSTALLING: ${line}"
    $AUR_HELPER -S --noconfirm --needed ${line}
  done
fi

export PATH=$PATH:~/.local/bin

# Theming DE if user chose FULL installation
if [[ $INSTALL_TYPE == "FULL" ]]; then
  if [[ $DESKTOP_ENV == "kde" ]]; then
    cp -r ~/Archie/configs/.local/share/* ~/.local/share/
    pipx install konsave
    konsave -i ~/Archie/configs/kde.knsv
    sleep 1
    konsave -a kde
 fi
fi

echo -ne "
-----------------------------------------------
                    SYSTEM READY FOR 3-post-setup.sh
-----------------------------------------------
"
exit
