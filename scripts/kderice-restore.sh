#!/bin/bash

export PATH=$PATH:~/.local/bin
cp -r $HOME/$SCRIPTHOME/configs/.config/* $HOME/.config/
pipx install konsave
konsave -i $HOME/$SCRIPTHOME/configs/kde.knsv
sleep 1
konsave -a kde
