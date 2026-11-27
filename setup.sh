#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")"

if [ ! -f .stow-local-ignore ]; then
  echo "Run setup.sh from the dotfiles repo root." >&2
  exit 1
fi

# Packages
sudo dpkg --add-architecture i386
sudo apt update
sudo apt upgrade -y

sudo apt install -y \
  ca-certificates \
  curl \
  ddcutil \
  fonts-font-awesome \
  gettext \
  ghostty \
  git \
  lazygit \
  make \
  neovim \
  npm \
  python3 \
  python3-pip \
  python3-venv \
  ripgrep \
  software-properties-common \
  steam \
  stow \
  tmux \
  vim \
  wget \
  zsh

# Snap packages
snap list freecad >/dev/null 2>&1 || sudo snap install freecad
snap list code >/dev/null 2>&1 || sudo snap install --classic code

# Third-party installers
if ! command -v docker >/dev/null 2>&1; then
  curl -fsSL https://get.docker.com | sh
fi
curl -fsS https://dl.brave.com/install.sh | sh
curl -fsSL https://claude.ai/install.sh | bash
curl -fsSL https://opencode.ai/v2/install | bash
curl -LsSf https://astral.sh/uv/install.sh | sh

sudo usermod -aG docker "$USER"
sudo npm install -g freebuff

# GNOME defaults
gnome-extensions disable ubuntu-dock@ubuntu.com
gsettings set org.gnome.desktop.default-applications.terminal exec 'ghostty --maximize'
xdg-settings set default-web-browser brave-browser.desktop

# Brave policies
sudo mkdir -p /etc/brave/policies/managed
sudo tee /etc/brave/policies/managed/bloat.json >/dev/null <<'EOF'
{
  "BraveRewardsDisabled": true,
  "BraveWalletDisabled": true,
  "BraveVPNDisabled": true,
  "BraveAIChatEnabled": false,
  "MetricsReportingEnabled": false,
  "BraveP3AEnabled": false,
  "BraveStatsPingEnabled": false,
  "BraveNewsDisabled": true,
  "BraveTalkDisabled": true,
  "SyncDisabled": true,
  "TorDisabled": true,
  "DnsOverHttpsMode": "automatic"
}
EOF

# Dotfiles and shell
stow . --adopt

sudo usermod -s "$(command -v zsh)" root
sudo chsh -s "$(command -v zsh)" "$USER"

if [ ! -d "$HOME/.oh-my-zsh" ]; then
  KEEP_ZSHRC=yes RUNZSH=no CHSH=no \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

plugin_dir="$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions"
if [ ! -d "$plugin_dir" ]; then
  git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions "$plugin_dir"
fi

# GitHub CLI
if ! command -v gh >/dev/null 2>&1; then
  sudo mkdir -p -m 755 /etc/apt/keyrings /etc/apt/sources.list.d

  curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg |
    sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg >/dev/null
  sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg

  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" |
    sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null

  sudo apt update
  sudo apt install -y gh
fi

gh auth status >/dev/null 2>&1 || gh auth login

# Brightness control (ddcutil)
sudo modprobe i2c-dev
echo i2c-dev | sudo tee /etc/modules-load.d/i2c-dev.conf >/dev/null

if [ -f /usr/share/ddcutil/data/60-ddcutil-i2c.rules ]; then
  sudo install -m 0644 /usr/share/ddcutil/data/60-ddcutil-i2c.rules /etc/udev/rules.d/60-ddcutil-i2c.rules
  sudo udevadm control --reload-rules || true
  sudo udevadm trigger --subsystem-match=i2c-dev || true
fi

sudo groupadd -f --system i2c
sudo usermod -aG i2c "$USER"

extension_dir="$HOME/gnome-display-brightness-ddcutil"
if [ ! -d "$extension_dir" ]; then
  git clone https://github.com/Tim-van-Oudheusden/gnome-display-brightness-ddcutil.git "$extension_dir"
fi
make -C "$extension_dir" install

gnome-extensions enable display-brightness-ddcutil@tim-van-oudheusden.github.io || true

cat <<'EOF'

Log out and back in for the GNOME changes to take effect:

  gnome-session-quit --logout --no-prompt
  gnome-extensions enable display-brightness-ddcutil@tim-van-oudheusden.github.io
EOF
