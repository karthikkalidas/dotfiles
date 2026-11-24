#!/bin/bash

sudo dpkg --add-architecture i386
sudo apt update
sudo apt upgrade
sudo apt install -y wget curl git vim tmux neovim ca-certificates software-properties-common steam ghostty stow zsh fonts-font-awesome npm python3 python3-pip python3-venv lazygit ripgrep gettext ddcutil

sudo snap install freecad
sudo snap install --classic code

curl -fsS https://dl.brave.com/install.sh | sh
curl -fsSL https://claude.ai/install.sh | bash
curl -fsSL https://opencode.ai/v2/install | bash
curl -LsSf https://astral.sh/uv/install.sh | sh

sudo npm install -g freebuff

# Update defaults
gnome-extensions disable ubuntu-dock@ubuntu.com
gsettings set org.gnome.desktop.default-applications.terminal exec 'ghostty --maximize'
xdg-settings set default-web-browser brave-browser.desktop

# Debloat Brave
sudo mkdir -p /etc/brave/policies/managed/
sudo tee /etc/brave/policies/managed/bloat.json >/dev/null <<'EOF'
{
  "BraveRewardsDisabled": true,
  "BraveWalletDisabled": true,
  "BraveVPNDisabled": true,
  "BraveAIChatEnabled": false,
  "MetricsReportingEnabled": false,
  "BraveP3AEnabled": false,
  "BraveStatsPingEnabled": false
  "BraveNewsDisabled": true,
  "BraveTalkDisabled": true,
  "SyncDisabled": true,
  "TorDisabled": true,
  "DnsOverHttpsMode": "automatic"
}
EOF

# OhMyZsh
sudo usermod -s $(which zsh) root
sudo chsh -s $(which zsh)
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# GithubCLI
(type -p wget >/dev/null || (sudo apt update && sudo apt install wget -y) ) &&
  sudo mkdir -p -m 755 /etc/apt/keyrings &&
  out=$(mktemp) && wget -nv -O$out https://cli.github.com/packages/githubcli-archive-keyring.gpg &&
  cat $out | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg >/dev/null &&
  sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg &&
  sudo mkdir -p -m 755 /etc/apt/sources.list.d &&
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null &&
  sudo apt update &&
  sudo apt install gh -y

gh auth login

# dotfiles
stow . --adopt

# Brightness control
sudo modprobe i2c-dev
echo i2c-dev | sudo tee /etc/modules-load.d/i2c-dev.conf >/dev/null

if [ -f /usr/share/ddcutil/data/60-ddcutil-i2c.rules ]; then
  sudo install -m 0644 /usr/share/ddcutil/data/60-ddcutil-i2c.rules /etc/udev/rules.d/60-ddcutil-i2c.rules
  sudo udevadm control --reload-rules || true
  sudo udevadm trigger --subsystem-match=i2c-dev || true
fi

sudo groupadd --system i2c
sudo usermod -aG i2c "$USER"

git clone "https://github.com/Tim-van-Oudheusden/gnome-display-brightness-ddcutil.git" "$HOME/gnome-display-brightness-ddcutil"
make -C "$HOME/gnome-display-brightness-ddcutil" install

gnome-extensions enable display-brightness-ddcutil@tim-van-oudheusden.github.io
echo "Relogin for GNOME changes to take affect, then run: gnome-extensions enable display-brightness-ddcutil@tim-van-oudheusden.github.io"
gnome-session-quit --logout --no-prompt
