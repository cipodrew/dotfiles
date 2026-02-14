# dotfiles per Linux.
Un adattamento di varie fonti

in continua evoluzione, non stabile

I dotfiles sono fatti in modo da funzionare anche senza installare il package manager Nix
Per l'installazione automatica di alcuni tool c'è la cartella home-manager (non é mia intenzione al momento usare home manager per configurare i dotfiles, ma solo per installare in modo dichiarativo pacchetti su Debian)
Per usare home-manager riferire a README.md nella cartella home-manager

# Installazione dotfiles
>[!Note]
>utile per avere una preview di quello che succederà é fare un dry-run
```bash 
cd $HOME/dotfiles && stow --simulate -S --verbose=2 .
cd $HOME/dotfiles/top-level && stow --simulate -S --verbose=2 * 
```


1. git clone della repo nella home folder, poi

2.
```bash 
 cd $HOME/dotfiles &&  stow -v . 
 cd $HOME/dotfiles/top-level && stow -v * 
```
 i file .stowrc si occupano di settare i target giusti

 3.  rendere eseguibili gli script
 4.  (opzionale) installare tpm per tmux
 5.  (opzionale) installare autosuggestions per zsh

# Installazione pacchetti
installare pacchetti che preferisco avere dal package manager della distro

```bash 
## sudo dnf install
sudo apt install \
git   \
gcc   \
make  \
stow  \
curl  \
xclip \
```
installare nix package manager (systemd multi user consigliato)
https://nixos.org/download/

installare home-manager (nix flake, standalone se si usa in distro non NixOS)
https://nix-community.github.io/home-manager/index.xhtml#sec-flakes-prerequisites
https://nix-community.github.io/home-manager/index.xhtml#sec-flakes-standalone

flake di configurazione già presenti
supponendo di avere un modulo nix di nome bebop.nix dove è presente la lista di pacchetti che vogliamo:

```bash
home-manager switch --flake ~/dotfiles/home-manager/#bebop
```

installare nvim da release github (per fare facilmente switch da una versiona all'altra
con symlinks):

```bash
myScripts/install-nvim.sh
```

## Uninstalling nvim completely for a fresh install
```bash
rm -rf ~/.config/nvim
rm -rf ~/.local/state/nvim
rm -rf ~/.local/share/nvim
```

## Comandi di manutenzione

```vim
:checkhealth  (ti dice quali azioni devi prendere per avere config corretta)
:Mason  (gestisce LSP)
:Lazy  (gestisce Plugin)
```
## Rollback Lazyvim plugins
using Lazy Lockfile

> [!Important] 
>se un upgrade ha rotto la config basta fare il git checkout di lazy.-lock.json del precedente git commit, poi eseguire il comando :LazyRestore
 
questo dovrebbe rifetchare i plugin con il commit che erano esettamente specificati all'epoca di quel lazy-lock.

