#!/bin/bash
source print_message.sh

if [ "$EUID" -eq 0 ]; then
  print_message "red" "[!] No puedes ejecutar este script como root."
  exit 1
fi

clear

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

sudo ./install.sh