#!/bin/bash
source print_message.sh
path=$(pwd)
dconf="https://raw.githubusercontent.com/otema666/my-packages/main/otema666.dconf"
dconfdir="/org/gnome/terminal/legacy/profiles:"
otema666_profile="otema666.dconf"

# otema666 theme function
create_new_profile() {
    dconf reset -f /org/gnome/terminal/legacy/profiles:/
    local profile_ids=($(dconf list $dconfdir/ | grep ^: | sed 's/\///g' | sed 's/://g'))
    local profile_name="$1"
    local profile_ids_old="$(dconf read "$dconfdir"/list | tr -d "]")"
    local profile_id="$(uuidgen)"

    [ -z "$profile_ids_old" ] && local profile_ids_old="["  # if there's no `list` key
    [ ${#profile_ids[@]} -gt 0 ] && local delimiter=,  # if the list is empty
    dconf write $dconfdir/list \
        "${profile_ids_old}${delimiter} '$profile_id']"

    while IFS= read -r line; do
        key=$(echo "$line" | cut -d '=' -f 1)
        value=$(echo "$line" | cut -d '=' -f 2-)
        dconf write "$dconfdir/:$profile_id/$key" "$value"
    done < "$otema666_profile"

    dconf write "$dconfdir/:$profile_id"/visible-name "'$profile_name'"
    echo $profile_id
}

# super + enter bind function
bind_fulls_terminal() {
  # Terminal (SUPER + ENTER)
  local terminal_path="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
  gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "['$terminal_path']"
  gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$terminal_path name 'Full Screen Terminal'
  gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$terminal_path command 'gnome-terminal --full-screen'
  gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$terminal_path binding '<Super>Return'
  print_message "yellow" "\t [+] Configurado Terminal Pantalla Completa: (WIN + ENTER)"

  # Brave (CTRL + ALT + B)
  local brave_path="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
  gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "['$brave_path']"
  gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$brave_path name 'Brave'
  gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$brave_path command 'brave'
  gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$brave_path binding '<Control><Alt>b'
  print_message "yellow" "\t [+] Configurado Brave Browser: (CTRL + ALT + B)"

  # Firefox  (CTRL + ALT + F)
  local firefox_path="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/"
  gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "['$firefox_path']"
  gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$firefox_path name 'Launch Firefox'
  gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$firefox_path command 'firefox'
  gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$firefox_path binding '<Control><Alt>f'
  print_message "yellow" "\t [+] Configurado Firefox Browser: (CTRL + ALT + F)"
}



# Check sudo
if [ "$EUID" -ne 0 ]; then
  print_message "red" "[!] Permiso denegado. Por favor ejecuta el programa como sudo."
  exit 1
fi

print_message "cyan" "===== Actualizando repositorios ====="
apt update && apt upgrade -y &> /dev/null
print_message "cyan" "===== Sistema actualizado correctamente =====\n"

print_message "cyan" "===== Instalando programas ====="

# Apt
apt_packages=("bat" "neovim" "curl" "exa" "aircrack-ng" "gcc" "ruby" "ruby-bundler" "ruby-dev" "octave" "git" "gparted" "nodejs" "gnome-tweaks" "gnome-shell-extensions" "keepassxc" "dbus-x11" "python3-pip" "tree")

for package in "${apt_packages[@]}"; do
    if dpkg-query -W -f='${Status}' "$package" 2>/dev/null | grep -q "install ok installed"; then
        print_message "yellow" "\t[-] $package ya estaba instalado."
    else
        print_message "green" "\t[+] Instalando $package..."
        apt install -y "$package" &> /dev/null
        if [ $? -eq 0 ]; then
            print_message "green" "\t\t [+] $package instalado correctamente."
        else
            print_message "red" "\t[!] Error al instalar $package."
        fi
    fi
done

# Speedtest
if command -v speedtest &> /dev/null; then
  print_message "yellow" "\t[-] Speedtest ya estaba instalado."
else
  print_message "green" "\t[+] Instalando speedtest..."
  if apt install -y speedtest; then
    print_message "green" "\t\t[-] Speedtest instalado correctamente."
  else
    print_message "yellow" "\tIntentando instalar Speedtest a través de script.deb.sh..."
    curl -s https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.deb.sh | sudo bash && apt-get install -y speedtest
    if [ $? -eq 0 ]; then
      print_message "green" "Speedtest instalado correctamente."
    else
      print_message "red" "\t[!] Error al instalar Speedtest."
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

# OhMyBash
print_message "cyan" "===== Configurando OhMyBash ====="
if [ -f ~/.bashrc ] && grep -q "oh-my-bash" ~/.bashrc; then
  print_message "yellow" "\t[-] OhMyBash ya está configurado en este sistema"
else
  print_message "green" "\t[+] Descargando OhMyBash"
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)" &> /dev/null
  echo "alias cat='batcat'" >> ~/.bashrc
  echo "alias ls='exa --icons'" >> ~/.bashrc
  sed -i 's/OSH_THEME=.*/OSH_THEME="axin"/' ~/.bashrc
  print_message "green" "\t\t[+] Configuración de Oh My Bash completada"
  fi


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

# gnomme-terminal
print_message "cyan" "===== Instalando tema de la terminal ====="

print_message "green" "\t[+] Descargando otema666 theme..."
if rm -f otema666.dconf  &&  wget $dconf &> /dev/null; then
  print_message "green" "\t\t[+] Descarga exitosa."
  print_message "green" "\t[+] Instalando tema..."
  if id=$(create_new_profile "otema666_profile"); then
    print_message "green" "\t[+] Tema instalado con éxito."
  else
    print_message "red" "\t\t[!] Error al instalar otema666 theme."
  fi
rm otema666.dconf
else
  print_message "red" "\t\t[!] Error al descargar otema666 theme."
fi

# Atajos de teclado
print_message "cyan" "===== Configurando atajos de teclado... ====="
if false && bind_fulls_terminal; then
  print_message "green" "\t[+] Atajos configurados correctamente."
else
  print_message "red" "\t[!] Esta funcion todavia no esta disponible."
  # print_message "red" "\t[!] Error al configurar atajos del teclado."
fi

print_message "cyan" "===== Actualizando repositorios ====="
apt update &> /dev/null
print_message "cyan" "===== Sistema actualizado correctamente ====="

exit 0

