
# My Configuration and Initial Linux Packages 💻

## Usage:

You can use the installer script with either wget or curl commands.

With wget:
```bash
wget -qO- https://raw.githubusercontent.com/otema666/my-packages/main/installer.sh | bash
```

or with curl:
```bash
curl -s https://raw.githubusercontent.com/otema666/my-packages/main/installer.sh | bash
```

## Keyboard Shortcuts

Here are some useful keyboard shortcuts to enhance your workflow:

- **Full Screen Terminal**: <kbd>Windows</kbd> + <kbd>Enter</kbd>
- **Open nautilus (file explorer)**: <kbd>Windows</kbd> + <kbd>E</kbd>
- **Close Active Window**: <kbd>Windows</kbd> + <kbd>W</kbd>
- **Switch to Workspace 1**: <kbd>Super</kbd> + <kbd>1</kbd>
- **Switch to Workspace 2**: <kbd>Super</kbd> + <kbd>2</kbd>
- **Switch to Workspace 3**: <kbd>Super</kbd> + <kbd>3</kbd>
- **Switch to Workspace 4**: <kbd>Super</kbd> + <kbd>4</kbd>
- **Move to Next Workspace**: <kbd>Super</kbd> + <kbd>Tab</kbd>
- **Move to Previous Workspace**: <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>Tab</kbd>
- **Move Window to Workspace 1**: <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>1</kbd>
- **Move Window to Workspace 2**: <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>2</kbd>
- **Move Window to Workspace 3**: <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>3</kbd>
- **Move Window to Workspace 4**: <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>4</kbd>
- **Brave Browser**: <kbd>Control</kbd> + <kbd>Alt</kbd> + <kbd>B</kbd>
- **Firefox Browser**: <kbd>Control</kbd> + <kbd>Alt</kbd> + <kbd>F</kbd>
- **Toogle battery power mode**: <kbd>Control</kbd> + <kbd>Alt</kbd> + <kbd>P</kbd>
## Personal Functions

Some custom functions that you can use in your terminal for improved productivity:

- **buscar**: Find files in a specific directory. Usage: `buscar <directory> <filename>`
- **firewall**: Launch the firewall manager. Just call `firewall` from the terminal.
- **server**: Start a local Python server. Usage: `server <directory> <port>`

## Apt packages
`bat ufw neovim nmap curl exa jq aircrack-ng net-tools gcc neofetch gnome-shell-extension-manager gir1.2-gtop-2.0 lm-sensors ruby ruby-bundler apache2-utils ruby-dev xdotool octave lolcat git gparted nodejs gnome-tweaks gnome-shell-extensions gnome-shell-extension-prefs keepassxc dbus-x11 python3-pip tree baobab`

## Snap packages

`code gimp brave discord vlc ngrok`

## Pip libraries

`gnome-extensions-cli numpy flask requests`

## Managing GNOME Extensions
This script utilizes the Python pip library [gnome-extensions-cli](https://github.com/essembeh/gnome-extensions-cli) to install and manage extensions. 

You can manage GNOME extensions via the GNOME Extensions website at [https://extensions.gnome.org/](https://extensions.gnome.org/). Simply visit the website and search for extensions by name or functionality. You can install, enable, disable, or remove extensions from there.


## Additional Configuration

- **OhMyBash**: OhMyBash will be automatically configured during the installation process. The script sets up OhMyBash and adjusts some aliases and settings for enhanced terminal usage.

- **Fonts**: The script installs the SauceCodePro font for better terminal aesthetics.

- **Improved ls with exa**: The script installs `exa`, an enhanced replacement for `ls`, to provide better formatting and additional features when listing files in the terminal. Additionally, it includes icons and adjusts the PATH to use `exa` instead of the default `ls` command.

- **Wallapaper:** This script autoinstall [this](https://github.com/otema666/my-packages/blob/main/assets/wallpaper.jpg?raw=true) wallapaper and save it into `/home/user/.wallapaper`.

## Ubuntu Configuration

This script has been configured and tested for:

- **Distributor ID**: Ubuntu
- **Description**: Ubuntu 22.04.3 LTS
- **Release**: 22.04
- **Codename**: jammy


![otema666](https://github.com/otema666/my-packages/assets/126337147/a511043d-62bd-4d5e-ba37-a43070736dad)
