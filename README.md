## One-click Ubuntu26 setup 

```bash
    curl -O https://raw.githubusercontent.com/karthikkalidas/dotfiles/refs/heads/master/setup.sh
    ./setup.sh
```


## For only applying dotfiles

```bash
    sudo apt install -y git stow
    git clone https://github.com/karthikkalidas/dotfiles.git
    cd dotfiles
    stow .
```
Use stow . --adopt to prevent overwriting existing dotfiles
