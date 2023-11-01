#!/bin/bash

# Checking if is running in Repo Folder
if [[ "$(basename "$(pwd)" | tr '[:upper:]' '[:lower:]')" =~ ^scripts$ ]]; then
    echo "You are running this in Archie Folder."
    echo "Please use ./archie.sh instead"
    exit
fi

# Installing git

echo "Installing git."
pacman -Sy --noconfirm --needed git glibc

echo "Cloning the Archie Project"
git clone https://github.com/Compourri/Archie

echo "Executing Archie Script"

cd Archie/

exec ./Archie.sh