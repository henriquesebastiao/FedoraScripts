#!/bin/bash

# Verifica se o script está sendo executado como root
if [[ $EUID -ne 0 ]]; then
   echo "Este script deve ser executado como root" 1>&2
   exit 1
fi

mkdir -p aplicativos && cd aplicativos

# Atualizando o sistema
dnf update -y > dnf_update.txt
if [ $? -ne 0 ]; then
  echo "Erro: Atualização DNF falhou, abortando!" >&2
  exit 1
fi

# Instalando RPM Fusion 
rpm -q rpmfusion-free-release || dnf install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm -y
rpm -q rpmfusion-nonfree-release || dnf install https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm -y

mkdir -p dnf && cd dnf

# Define a list of dnf packages to install
dnfs=(
    epiphany
    vlc
    python-vlc
    audacity
    gnome-tweaks
    sqlitebrowser
    filezilla
    wireshark
    qbittorrent
    bpytop
)

# Instalando aplicativos e salvando saídas
for app in ${dnfs[@]}
do
    dnf install $app -y > $app.txt
    if [ $? -ne 0 ]; then
      echo "Falha ao instalar: $app."
      exit 1
    fi
done

#######################################################

# Flatpaks
cd ..
mkdir flatpaks
cd flatpaks

flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo # Habilitando flathub

# Define a list of flatpaks from flathub to install
flatpaks=(
    io.github.shiftey.Desktop
    com.authy.Authy
    nl.hjdskes.gcolor3
    org.gnome.design.Palette
    com.github.finefindus.eyedropper
    com.borgbase.Vorta
)

# Check if flatpak is installed
if ! command -v flatpak &> /dev/null
then
    echo "Flatpak não instalado"
    exit
fi

# Install each flatpak in the list
for flatpak in ${flatpaks[@]}
do
    flatpak install flathub $flatpak
    if [ $? -ne 0 ]; then
      echo "Falha ao instalar flatpak: $flatpak."
      exit 1
    fi
done

#######################################################

#OUTROS
cd ..

#VS Code
rpm --import https://packages.microsoft.com/keys/microsoft.asc
sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
dnf check-update
dnf install code -y
if [ $? -ne 0 ]; then
  echo "Falha instalar: VS Code."
  exit 1
fi

# Bitwarden CLI
wget https://vault.bitwarden.com/download/?app=cli&platform=linux
if [ $? -ne 0 ]; then
  echo "Falha instalar: Bitwarden CLI."
  exit 1
fi
cp bw /usr/bin
echo bw > ~/Aplicativos/pasta_bin.txt
#######################################################

#RPMs
mkdir RPMs
cd RPMs

# -> Google Earth Pro
wget https://dl.google.com/dl/earth/client/current/google-earth-pro-stable-current.x86_64.rpm
if [ $? -ne 0 ]; then
  echo "Falha no download: Google Earth Pro."
  exit 1
fi

# Instala todos os RPMs
rpms =( *.rpm))
for rpm in ${rpms[@]}
do
    sudo dnf install $rpm -y > $rpm.txt
    if [ $? -ne 0 ]; then
      echo "Falha ao instalar RPM: $rpm."
      exit 1
    fi
    rm $rpm
done

cd ..

#######################################################

# APPIMAGE
mkdir AppImage
cd AppImage

# -> Bitwarden GUI
wget https://vault.bitwarden.com/download/?app=desktop&platform=linux
if [ $? -ne 0 ]; then
  echo "Falha no download: Bitwarden."
  exit 1
fi

unzip *.zip
rm bw-*

------------------------------------------------------------------------------
# Download latest Bitwarden AppImage
wget https://vault.bitwarden.com/download/?app=desktop -O Bitwarden.AppImage
if [ $? -ne 0 ]; then
  echo "Failed to download Bitwarden."
  exit 1
fi

# Make it executable
chmod +x Bitwarden.AppImage
# Copy to /usr/bin
cp Bitwarden.AppImage /usr/bin
# Add to the list of apps to be added to the menu
echo Bitwarden.AppImage >> ~/aplicativos/pasta_bin.txt
cd ..
#######################################################

# TAR.GZ
mkdir -p tar_gz && cd tar_gz

# -> PyCharm
wget https://download-cdn.jetbrains.com/python/pycharm-professional-2022.3.2.tar.gz # ATUALIZAR LINK
if [ $? -ne 0 ]; then
  echo "Failed to download PyCharm."
  exit 1
fi

# -> IntelliJ IDEA
wget https://download-cdn.jetbrains.com/idea/ideaIU-2022.3.3.tar.gz # ATUALIZAR LINK
if [ $? -ne 0 ]; then
  echo "Failed to download IntelliJ IDEA."
  exit 1
fi

# -> PhpStorm
wget https://download-cdn.jetbrains.com/webide/PhpStorm-2022.3.2.tar.gz # ATUALIZAR LINK
if [ $? -ne 0 ]; then
  echo "Failed to download PhpStorm."
  exit 1
fi

# -> WebStorm
wget https://download-cdn.jetbrains.com/webstorm/WebStorm-2022.3.2.tar.gz # ATUALIZAR LINK
if [ $? -ne 0 ]; then
  echo "Failed to download WebStorm."
  exit 1
fi

# -> CLion
wget https://download-cdn.jetbrains.com/cpp/CLion-2022.3.2.tar.gz # ATUALIZAR LINK
if [ $? -ne 0 ]; then
  echo "Failed to download CLion."
  exit 1
fi

# This script uncompresses all tar.gz files in the current directory.
for file in *tar.gz
do
    if [[ -f $file ]]
    then
        echo "Uncompressing: $file"
        tar -xvzf $file
        rm $file
    fi
done

# -> Tor Browser
wget https://dist.torproject.org/torbrowser/12.0.3/tor-browser-linux64-12.0.3_ALL.tar.xz # ATUALIZAR LINK
if [ $? -ne 0 ]; then
  echo "Failed to download Tor Browser."
  exit 1
fi
tar -Jxvf tor-browser-linux64-12.0.3_ALL.tar.xz
if [ $? -ne 0 ]; then
  echo "Failed to uncompress Tor Browser."
  exit 1
fi
rm *.tar.xz