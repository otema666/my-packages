#!/bin/bash

clear
path=$(pwd)

print_message() {
  case "$1" in
    "green") echo -e "\e[32m$2\e[0m";;
    "yellow") echo -e "\e[33m$2\e[0m";;
    "red") echo -e "\e[31m$2\e[0m";;
    "cyan") echo -e "\e[36m$2\e[0m";;
    *) echo "$2";;
  esac
}

print_message "cyan" "===== Actualizando repositorios ====="
apt update && apt upgrade -y &> /dev/null
print_message "cyan" "===== Sistema actualizado correctamente =====\n"

print_message "cyan" "===== Instalando programas ====="

# Apt
apt_packages=("bat" "neovim" "curl" "exa" "aircrack-ng" "gcc" "ruby" "octave" "git" "gparted" "nodejs" "gnome-tweaks")

for package in "${apt_packages[@]}"; do
  if dpkg -l | grep -q $package; then
    print_message "yellow" "\t[-] $package ya estaba instalado."
  else
    apt install -y $package
    if [ $? -eq 0 ]; then
      print_message "green" "$package instalado correctamente."
    else
      print_message "red" "Error al instalar $package."
    fi
  fi
done

# Speedtest
if command -v speedtest &> /dev/null; then
  print_message "yellow" "\t[-] Speedtest ya estaba instalado."
else
  if apt install -y speedtest; then
    print_message "green" "Speedtest instalado correctamente."
  else
    print_message "yellow" "Intentando instalar Speedtest a través de script.deb.sh..."
    curl -s https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.deb.sh | sudo bash && apt-get install -y speedtest
    if [ $? -eq 0 ]; then
      print_message "green" "Speedtest instalado correctamente."
    else
      print_message "red" "Error al instalar Speedtest."
    fi
  fi
fi

# Snap
snap_packages=("code" "gimp" "brave" "discord" "vlc")

for package in "${snap_packages[@]}"; do
  if snap list | grep -q "$package"; then
    print_message "yellow" "\t[-] \"$package\" ya está instalado."
  else
    snap install $package
    if [ $? -eq 0 ]; then
      print_message "green" "$package instalado correctamente."
    else
      print_message "red" "Error al instalar $package."
    fi
  fi
done

print_message "cyan" "===== Instalando fuentes ====="

# Font: SauceCodePro
if fc-list | grep -q "SauceCodePro"; then
  print_message "yellow" "\t[-] La fuente SauceCodePro ya estaba instalada."
else
  wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/SauceCodePro.zip -P /usr/share/fonts/ && \
  unzip /usr/share/fonts/SauceCodePro.zip -d /usr/share/fonts/ && \
  rm /usr/share/fonts/SauceCodePro.zip && \
  rm /usr/share/fonts/README.md && \
  rm /usr/share/fonts/LICENSE.txt && \
  cd $path
  print_message "green" "Fuente SauceCodePro instalada correctamente."
fi

print_message "cyan" "===== Actualizando repositorios ====="
apt update &> /dev/null
print_message "cyan" "===== Sistema actualizado correctamente ====="

exit 0

