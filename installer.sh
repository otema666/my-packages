#!/bin/bash

# var
path=$(pwd)
prerequisites=("lolcat" "figlet")
apt_packages=("bat" "neovim" "curl" "exa" "aircrack-ng" "net-tools" "gcc" "neofetch" "ruby" "ruby-bundler" "ruby-dev" "octave" "lolcat" "git" "gparted" "nodejs" "gnome-tweaks" "gnome-shell-extensions" "gnome-shell-extension-prefs" "keepassxc" "dbus-x11" "python3-pip" "tree" "baobab")
snap_packages=("code --classic" "gimp" "brave" "discord" "vlc")
message=0
dconf="https://raw.githubusercontent.com/otema666/my-packages/main/otema666.dconf"
dconfdir="/org/gnome/terminal/legacy/profiles:"
otema666_profile="otema666.dconf"

# functions
print_message() {
  case "$1" in
    "green") echo -e "\e[32m$2\e[0m";;
    "yellow") echo -e "\e[33m$2\e[0m";;
    "red") echo -e "\e[31m$2\e[0m";;
    "cyan") echo -e "\e[36m$2\e[0m";;
    *) echo "$2";;
  esac
}

ctrl_c() {
  print_message "red" "\n[!] Detectado ctrl+c, saliendo..."
  exit 1
}

trap 'ctrl_c' INT

check_internet_connection() {
    wget -q --spider http://example.com
    if [ $? -eq 0 ]; then
        return 0
    else
        return 1
    fi
}

# config extension
gnome_extension() {
  if ! gnome-extensions list | grep -q ding@rastersoft.com; then
    gnome-extensions disable ding@rastersoft.com
  fi
  if ! gnome-extensions list | grep -q ubuntu-dock@ubuntu.com; then
    gnome-extensions disable ubuntu-dock@ubuntu.com
  fi

  if [ ! -d "$HOME/.local/share/gnome-shell/extensions/search-light" ]; then
    git clone https://github.com/icedman/search-light ~/.local/share/gnome-shell/extensions/search-light
    cd ~/.local/share/gnome-shell/extensions/search-light
    make
    cd $path
  else
    print_message "yellow" "\t[-] La extensión de búsqueda ya está instalada."
  fi
}

wallpaper() {
  wget -q "https://github.com/otema666/my-packages/blob/main/assets/wallpaper.jpg" -O ~/wallpaper.jpg
  gsettings set org.gnome.desktop.background picture-uri-dark "file://$HOME/wallpaper.jpg"
}

# otema666 theme function
create_new_profile() {
    sudo dconf reset -f /org/gnome/terminal/legacy/profiles:/
    local profile_ids=($(sudo dconf list $dconfdir/ | grep ^: | sed 's/\///g' | sed 's/://g'))
    local profile_name="$1"
    local profile_ids_old="$(sudo dconf read "$dconfdir"/list | tr -d "]")"
    local profile_id="$(uuidgen)"

    [ -z "$profile_ids_old" ] && local profile_ids_old="["  # if there's no `list` key
    [ ${#profile_ids[@]} -gt 0 ] && local delimiter=,  # if the list is empty
    sudo dconf write $dconfdir/list \
        "${profile_ids_old}${delimiter} '$profile_id']"

    while IFS= read -r line; do
        key=$(echo "$line" | cut -d '=' -f 1)
        value=$(echo "$line" | cut -d '=' -f 2-)
        sudo dconf write "$dconfdir/:$profile_id/$key" "$value"
    done < "$otema666_profile"

    sudo dconf write "$dconfdir/:$profile_id"/visible-name "'$profile_name'"
    echo $profile_id
}


# super + enter bind function
bind_fulls_terminal() {
  # Terminal (SUPER + ENTER)
  local terminal_path="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
  sudo gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "['$terminal_path']"
  sudo gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$terminal_path name 'Full Screen Terminal'
  sudo gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$terminal_path command 'gnome-terminal --full-screen'
  sudo gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$terminal_path binding '<Super>Return'
  print_message "yellow" "\t [+] Configurado Terminal Pantalla Completa: (WIN + ENTER)"

  # Brave (CTRL + ALT + B)
  local brave_path="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
  sudo gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "['$brave_path']"
  sudo gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$brave_path name 'Brave'
  sudo gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$brave_path command 'brave'
  sudo gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$brave_path binding '<Control><Alt>b'
  print_message "yellow" "\t [+] Configurado Brave Browser: (CTRL + ALT + B)"

  # Firefox  (CTRL + ALT + F)
  local firefox_path="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/"
  sudo gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "['$firefox_path']"
  sudo gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$firefox_path name 'Launch Firefox'
  sudo gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$firefox_path command 'firefox'
  sudo gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$firefox_path binding '<Control><Alt>f'
  print_message "yellow" "\t [+] Configurado Firefox Browser: (CTRL + ALT + F)"
}

variables_personales (){
    if if ! grep -q "buscar()" ~/.bashrc; then
        print_message "yellow" "\t\t[-] Añadiendo función buscar..."
        echo "buscar() {" >> ~/.bashrc
        echo '  sudo find "$2" -name "$1"' >> ~/.bashrc
        echo "}" >> ~/.bashrc
    fi
}

# Start with program.
if [ "$EUID" -eq 0 ]; then
  print_message "red" "[!] No puedes ejecutar este script como root."
  exit 1
fi

if ! check_internet_connection; then
    print_message "red" "[!] Sin conexión a internet, compruebe su conexión a internet e inténtelo de nuevo."
    exit 1
fi

for package in "${prerequisites[@]}"; do
    if ! dpkg-query -W -f='${Status}' "$package" 2>/dev/null | grep -q "install ok installed"; then
        if [ $message -eq 0 ]; then
            print_message "yellow" "[*] Cargando..."
            message=1
        fi
        sudo apt install -y "$package" &> /dev/null
        if [ ! $? -eq 0 ]; then
            print_message "red" "\t[!] Error al instalar $package."            
        fi
    fi
done

clear && figlet "Auto installer" -c | lolcat

if gsettings set org.gnome.desktop.interface color-scheme prefer-dark; then
  print_message "[+] Tema oscuro aplicado."
else
  print_message "red" "\t Error al configurar el modo oscuro."
fi

print_message "cyan" "===== Configurando barra superior... ====="
if gsettings set org.gnome.desktop.interface clock-show-seconds true; then
  print_message "green" "\t[+] Mostrar segundos activado"
else
  print_message "red" "\t[!] Error al activar mostrar segundos."
fi

if gsettings set org.gnome.desktop.interface enable-hot-corners false; then
  print_message "green" "\t[+] Botón de actividades no animado"
else
  print_message "red" "\t[!] Error al configurar botón de actividades."
fi


# Extension
print_message "cyan" "===== Configurando extensiones... ====="
if gnome_extension; then
  print_message "green" "\t[+] Extensiones configuradas correctamente."
else
  print_message "red" "\t[!] Error al configurar las extensiones."
  # print_message "red" "\t[!] Error al configurar atajos del teclado."
fi

# Background
print_message "cyan" "===== Configurando fondo de pantalla... ====="
if wallpaper; then
  print_message "green" "\t[+] Configurado correctamente"
else
  print_message "red" "\t[!] Error al configurar el fondo de pantalla"
fi

# start with sudo
print_message "cyan" "===== Actualizando repositorios ====="
sudo apt update && sudo apt upgrade -y &> /dev/null
print_message "cyan" "===== Sistema actualizado correctamente =====\n"

print_message "cyan" "===== Instalando programas ====="

# Apt

for package in "${apt_packages[@]}"; do
    if dpkg-query -W -f='${Status}' "$package" 2>/dev/null | grep -q "install ok installed"; then
        print_message "yellow" "\t[-] $package ya estaba instalado."
    else
        print_message "green" "\t[+] Instalando $package..."
        sudo apt install -y "$package" &> /dev/null
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
  if sudo apt install -y speedtest; then
    print_message "green" "\t\t[-] Speedtest instalado correctamente."
  else
    print_message "yellow" "\tIntentando instalar Speedtest a través de script.deb.sh..."
    curl -s https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.deb.sh | sudo bash && sudo apt-get install -y speedtest
    if [ $? -eq 0 ]; then
      print_message "green" "Speedtest instalado correctamente."
    else
      print_message "red" "\t[!] Error al instalar Speedtest."
    fi
  fi
fi

# Snap
for package in "${snap_packages[@]}"; do
  if snap list | grep -q "$package"; then
    print_message "yellow" "\t[-] \"$package\" ya está instalado."
  else
    sudo snap install $package
    if [ $? -eq 0 ]; then
      print_message "green" "\t[+] $package instalado correctamente."
    else
      print_message "red" "\t[!] Error al instalar $package."
    fi
  fi
done

# OhMyBash
print_message "cyan" "===== Configurando OhMyBash ====="
if [ -f ~/.bashrc ] && grep -q "oh-my-bash" ~/.bashrc; then
  print_message "yellow" "\t[-] OhMyBash ya está configurado en este sistema"
else
  print_message "green" "\t[+] Descargando OhMyBash"
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)"
  echo "alias cat='batcat'" | sudo tee -a ~/.bashrc
  echo "alias ls='exa --icons'" | sudo tee -a ~/.bashrc
  sudo sed -i 's/OSH_THEME=.*/OSH_THEME="axin"/' ~/.bashrc
  print_message "green" "\t\t[+] Configuración de Oh My Bash completada"
  fi


print_message "cyan" "===== Instalando fuentes ====="

# Font: SauceCodePro
if fc-list | grep -q "SauceCodePro"; then
  print_message "yellow" "\t[-] La fuente SauceCodePro ya estaba instalada."
else
  sudo wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/SauceCodePro.zip -P /usr/share/fonts/ && \
  sudo unzip /usr/share/fonts/SauceCodePro.zip -d /usr/share/fonts/ && \
  sudo rm /usr/share/fonts/SauceCodePro.zip && \
  sudo rm /usr/share/fonts/README.md && \
  sudo rm /usr/share/fonts/LICENSE.txt && \
  cd $path
  print_message "green" "Fuente SauceCodePro instalada correctamente."
fi

# gnomme-terminal
print_message "cyan" "===== Instalando tema de la terminal ====="

print_message "green" "\t[+] Descargando otema666 theme..."
if sudo rm -f otema666.dconf  &&  wget $dconf &> /dev/null; then
  print_message "green" "\t\t[+] Descarga exitosa."
  print_message "green" "\t[+] Instalando tema..."
  if id=$(create_new_profile "otema666_profile"); then
    print_message "green" "\t[+] Tema instalado con éxito."
  else
    print_message "red" "\t\t[!] Error al instalar otema666 theme."
  fi
sudo rm otema666.dconf
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

print_message "cyan" "===== Configurando variables personales... ====="
variables_personales

print_message "cyan" "===== Actualizando repositorios ====="
sudo apt update &> /dev/null
print_message "cyan" "===== Sistema actualizado correctamente ====="

exit 0
