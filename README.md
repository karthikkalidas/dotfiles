## One-click Ubuntu 26 setup

```bash
git clone https://github.com/karthikkalidas/dotfiles.git
cd dotfiles
./setup.sh
```

## For only applying dotfiles

```bash
sudo apt install -y git stow
git clone https://github.com/karthikkalidas/dotfiles.git
cd dotfiles
stow .
```

Use `stow . --adopt` if `$HOME` already contains conflicting files; it moves them into the repo instead of failing.
