#!/bin/bash

# var
path=$(pwd)
prerequisites=("lolcat" "figlet")
apt_packages=("bat" "ufw" "neovim" "nmap" "curl" "exa" "jq" "aircrack-ng" "net-tools" "gcc" "neofetch" "gnome-shell-extension-manager" "gir1.2-gtop-2.0" "lm-sensors" "ruby" "ruby-bundler" "apache2-utils" "ruby-dev" "xdotool" "octave" "lolcat" "git" "gparted" "nodejs" "gnome-tweaks" "gnome-shell-extensions" "gnome-shell-extension-prefs" "keepassxc" "dbus-x11" "python3-pip" "tree" "baobab" "htop" "libnotify-bin")
snap_packages=("gimp" "brave" "discord" "vlc" "ngrok")
pip_packages=("gnome-extensions-cli" "numpy" "flask" "requests")
message=0
dconf="https://raw.githubusercontent.com/otema666/my-packages/main/otema666.dconf"
nano7_2="https://www.nano-editor.org/dist/latest/nano-7.2.tar.gz"
dconfdir="/org/gnome/terminal/legacy/profiles:"
otema666_profile="otema666.dconf"
extension_list=(
  lockkeys@fawtytoo
  Vitals@CoreCoding.com
  horizontal-workspace-indicator@tty2.io
  search-light@icedman.github.com
  )

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
  extension_in_system=$(gnome-extensions list)
  for installed_extension in "${extension_in_system[@]}";do
    gext uninstall $installed_extension &> /dev/null
  done
  if gnome-extensions list | grep -q ding@rastersoft.com; then
    gnome-extensions disable ding@rastersoft.com
    print_message "green" "\t[+] Desactivado mostrar iconos del escritorio."
  fi
  
  if gnome-extensions list | grep -q ubuntu-dock@ubuntu.com; then
    gnome-extensions disable ubuntu-dock@ubuntu.com
    print_message "green" "\t[+] Desactivado mostrar dock."
  fi

  gsettings set org.gnome.desktop.wm.preferences focus-new-windows 'smart'

  for extension in "${extension_list[@]}"; do
    if gext install "$extension" 2>&1 | grep -q "is already installed"; then
        print_message "yellow" "\t[-] La extensión $extension ya estaba instalada."
    else
      print_message "green" "\t[+] Instalada $extension"
    fi
    gext enable "$extension" &> /dev/null
  done
  print_message "cyan" "\t== Actualizando extensiones... == "
  gext update &> /dev/null
  print_message "green" "\t [+] Actualizadas con exito. Lista de extensiones:"
  gext list

}

wallpaper() {
  wget -q "https://github.com/otema666/my-packages/blob/main/assets/wallpaper.jpg?raw=true" -O ~/.wallpaper.jpg
  sleep 1.5
  gsettings set org.gnome.desktop.background picture-uri "file://$HOME/.wallpaper.jpg"
  gsettings set org.gnome.desktop.background picture-uri-dark "file://$HOME/.wallpaper.jpg"
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
  local terminal_path="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
  local brave_path="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
  local firefox_path="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/"
  local nautilus_path="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/"
  
  local keybindings="[ '$terminal_path', '$brave_path', '$firefox_path', '$nautilus_path' ]"

  gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "$keybindings"

  # Terminal (SUPER + ENTER)
  gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$terminal_path name 'Full Screen Terminal'
  gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$terminal_path command 'gnome-terminal --full-screen'
  gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$terminal_path binding '<Super>Return'
  print_message "yellow" "\t [+] Configurado Terminal Pantalla Completa: (SUPER + ENTER)"

  # Brave (CTRL + ALT + B)
  gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$brave_path name 'Brave'
  gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$brave_path command 'brave'
  gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$brave_path binding '<Control><Alt>b'
  print_message "yellow" "\t [+] Configurado Brave Browser: (CTRL + ALT + B)"

  # Firefox  (CTRL + ALT + F)
  gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$firefox_path name 'Launch Firefox'
  gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$firefox_path command 'firefox'
  gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$firefox_path binding '<Control><Alt>f'
  print_message "yellow" "\t [+] Configurado Firefox Browser: (CTRL + ALT + F)"
  
  # Close current window (Super + W)
  gsettings set org.gnome.desktop.wm.keybindings close "['<Super>w']"
  print_message "yellow" "\t [+] Configurado cerrar la ventana activa: (Super + W)"

  # Open nautilus (Super + E)
  gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$nautilus_path name 'Nautilus'
  gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$nautilus_path command 'nautilus'
  gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$nautilus_path binding '<Super>e'
  print_message "yellow" "\t [+] Configurado abrir explorador de archivos: (Super + E)"

  # Config workspaces
  gsettings set org.gnome.mutter dynamic-workspaces false
  gsettings set org.gnome.desktop.wm.preferences num-workspaces 4

  # Workspace 1 (Super + 1)
  gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-1 "['<Super>1']"
  print_message "yellow" "\t [+] Configurado cambiar Workspace 1: (Super + 1)"

  # Workspace 2 (Super + 2)
  gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-2 "['<Super>2']"
  print_message "yellow" "\t [+] Configurado cambiar Workspace 2: (Super + 1)"

  # Workspace 3 (Super + 3)
  gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-3 "['<Super>3']"
  print_message "yellow" "\t [+] Configurado cambiar Workspace 3: (Super + 1)"

  # Workspace 4 (Super + 4)
  gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-4 "['<Super>4']"
  print_message "yellow" "\t [+] Configurado cambiar Workspace 4: (Super + 1)"

  # Move to next workspace (Super + Tab)
  gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-right "['<Super>Tab']"
  print_message "yellow" "\t [+] Configurado mover a siguiente Workspace: (Super + Tab)"

  # Move to previous workspace (Super + Shift + Tab)
  gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-left "['<Super><Shift>Tab']"
  print_message "yellow" "\t [+] Configurado mover a anterior Workspace: (Super + Shift + Tab)"

  # Move window to workspace 1 (Super + Shift + 1)
  gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-1 "['<Super><Shift>1']"
  print_message "yellow" "\t [+] Configurado mover ventana a Workspace 1: (Super + Shift + 1)"

  # Move window to workspace 2 (Super + Shift + 2)
  gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-2 "['<Super><Shift>2']"
  print_message "yellow" "\t [+] Configurado mover ventana a Workspace 2: (Super + Shift + 2)"

  # Move window to workspace 3 (Super + Shift + 3)
  gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-3 "['<Super><Shift>3']"
  print_message "yellow" "\t [+] Configurado mover ventana a Workspace 3: (Super + Shift + 3)"

  # Move window to workspace 4 (Super + Shift + 4)
  gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-4 "['<Super><Shift>4']"
  print_message "yellow" "\t [+] Configurado mover ventana a Workspace 4: (Super + Shift + 4)"
}

variables_personales (){
  if ! grep -q "alias open='xdg-open'" ~/.bashrc; then
    print_message "yellow" "\t\t[-] Añadiendo alias open..."
    echo "alias open='xdg-open'" >> ~/.bashrc
  fi

  if ! grep -q "buscar()" ~/.bashrc; then
    print_message "yellow" "\t\t[-] Añadiendo función buscar..."
    echo "buscar() {" >> ~/.bashrc
    echo '  sudo find "$2" -name "$1"' >> ~/.bashrc
    echo "}" >> ~/.bashrc
  fi
  
  if ! grep -q "server()" ~/.bashrc; then
    print_message "yellow" "\t\t[-] Añadiendo función server..."
    echo " " >> ~/.bashrc
    echo "# Funcion servidor de python" >> ~/.bashrc
    echo "server() {" >> ~/.bashrc
    echo '  if [ $# -eq 0 ]; then' >> ~/.bashrc
    echo '    echo "Uso: server <directorio> <puerto>"' >> ~/.bashrc
    echo '    return 1' >> ~/.bashrc
    echo '  fi' >> ~/.bashrc
    echo '  sudo python3 -m http.server --directory $1 $2'  >> ~/.bashrc
    echo "}" >> ~/.bashrc
  fi
}

firewall() {
    if [ -d "$HOME/bin" ] && [ -f "$HOME/bin/firewall" ]; then
        print_message "yellow" "\t[-] La funcion firewall ya estaba configurada."
        return
    fi

    if [ ! -d "$HOME/bin" ]; then
        mkdir "$HOME/bin"
        print_message "green" "\t[+] Created directory ~/bin"
    fi

    print_message "cyan" "\t\t [*] Descargando firewall.sh de otema666 (https://github.com/otema666/ubuntu-ufw-manager)..."
    wget -q -O "$HOME/bin/firewall.sh" "https://raw.githubusercontent.com/otema666/ubuntu-ufw-manager/main/firewall.sh"
    sudo chmod +x "$HOME/bin/firewall.sh"
    sudo mv firewall.sh firewall
    # Agregar ~/bin al PATH en el archivo .bashrc si no estaba agregado previamente
    if ! grep -qF "$HOME/bin" "$HOME/.bashrc"; then
        echo "Adding ~/bin to PATH in .bashrc..."
        echo "" >> "$HOME/.bashrc"
        echo "# Add ~/bin to PATH" >> "$HOME/.bashrc"
        echo 'export PATH="$HOME/bin:$PATH"' >> "$HOME/.bashrc"
        echo "Added ~/bin to PATH in .bashrc."
    fi
    
    print_message "green" "\t[+] Funcion firewall configurada con exito."
}

config_nano() {
  nano_improved_repo="$HOME/.nano/readme.md"
  print_message "cyan" "==== Configurando nanorc... ===="
  
  if [ ! -f "$nano_improved_repo" ]; then
    curl https://raw.githubusercontent.com/scopatz/nanorc/master/install.sh | sh &> /dev/null 
    print_message "green" "\t[-] Nano configurado."
  else
    print_message "yellow" "\t[-] Nano ya estaba configurado."  
  fi
}

powerprofiles() {
  print_message "cyan" "==== Configurando Atajo para alternar modo de energía... ===="

  echo "# Performance / Ahorro de energia script (Fn + F5)" >> $HOME/.xbindkeysrc
  echo '"bash $HOME/powerprofiles.sh"' >> $HOME/.xbindkeysrc
  echo "   Control + Alt + p" >> $HOME/.xbindkeysrc
  killall -s1 xbindkeys
  xbindkeys

  wget -q "https://raw.githubusercontent.com/otema666/my-packages/main/powerprofiles.sh" -O ~/powerprofiles.sh

  print_message "green" "\t[-] Atajo para alternar modo de energía configurado."

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
if snap list | grep -q "code"; then
  print_message "yellow" "\t[-] "vscode" ya está instalado."
else
  sudo snap install code --classic
  print_message "green" "\t[+] vscode instalado correctamente."

fi
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

# pip
for package in "${pip_packages[@]}"; do
  if pip3 show "$package" &> /dev/null; then
    print_message "yellow" "\t[-]$package ya estaba instalado"
  else
    print_message "green" "\t[+] Instalando $package..."
    pip3 install "$package" &> /dev/null
    if [ $? -eq 0 ]; then
        print_message "green" "\t\t [+] $package instalado correctamente."
    else
        print_message "red" "\t[!] Error al instalar $package."
    fi
  fi
done

print_message "cyan" "===== Configurando función firewall... ====="
firewall

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
fi

# Background
print_message "cyan" "===== Configurando fondo de pantalla... ====="
if wallpaper; then
  print_message "green" "\t[+] Configurado correctamente"
else
  print_message "red" "\t[!] Error al configurar el fondo de pantalla"
fi

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
  print_message "yellow" "\t[-] La fuente SourceCodePro ya estaba instalada."
else
  sudo wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/SourceCodePro.zip -P /usr/share/fonts/ && \
  sudo unzip /usr/share/fonts/SourceCodePro.zip -d /usr/share/fonts/SourceCodePro && \
  sudo rm -f /usr/share/fonts/SourceCodePro.zip && \
  sudo rm -f /usr/share/fonts/SourceCodePro/README.md && \
  sudo rm -f /usr/share/fonts/SourceCodePro/LICENSE.txt && \
  cd $path
  print_message "green" "Fuente SourceCodePro instalada correctamente."
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

# Configuracion de nano
config_nano

powerprofiles

# Atajos de teclado
print_message "cyan" "===== Configurando atajos de teclado... ====="
if bind_fulls_terminal; then
  print_message "green" "\t[+] Atajos configurados correctamente."
else
  print_message "red" "\t[!] Error al configurar atajos del teclado."
fi

print_message "cyan" "===== Configurando variables personales... ====="
variables_personales

if [ "$(pwd)" != "$path" ]; then
  cd "$path"
fi


print_message "cyan" "===== Actualizando repositorios ====="
sudo apt update &> /dev/null
print_message "cyan" "===== Sistema actualizado correctamente =====\n"

print_message "red" "Es necesario cerrar sesión para aplicar la configuración"
sleep 3
gnome-session-quit

exit 0
