PROMPT='%n@%m:%~$ '
#Get aliases
source "$HOME/.zsh_aliases"

#plugins
source ~/clonedRepos/zsh-autosuggestions/zsh-autosuggestions.zsh

#Keybindings
bindkey -e   #emacs mode
#Ctrl+f -> accept completion
#Ctrl+a -> move to start of line
#Ctrl+e -> move to end of line
#Ctrl+b -> back one char
#Alt+b -> back one word
#Analogo in avanti con F al posto di B
#Cltr+u -> deleto from cursor to beginning of line
#Cltr+k -> deleto from cursor to end of line
#Cltr+w -> deleto from cursor to start of word
#Alt+D -> deleto word after the cursor
#Cltr+y -> paste from text buffer, which store what you deleted with ctrl u/k/w
#Ctrl+x Ctrl+u -> Undo the last changes.

#Alt+r -> Undo all changes to the line.
#Alt+Ctrl+e -> Expand command line.
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward

# History
HISTSIZE=2000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space #Se la linea di comando inizia con uno spazio non viene salvata, utile se si devono usare dei secrets
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Completion styling
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

#zoxide
eval "$(zoxide init zsh)"

#fzf
#Append this line to ~/.bashrc to enable fzf keybindings for zsh:
# https://github.com/junegunn/fzf/blob/v0.59.0/shell/key-bindings.zsh
source /usr/share/doc/fzf/examples/key-bindings.zsh


#print something on startup
#[ -z "${TMUX}" ] && figlet -t "Hello There!" | lolcat
#[ -z "${TMUX}" ] && pfetch #run pfetch if not in tmux
if [ "$TERM_PROGRAM" != tmux ] && [ "$TERM_PROGRAM" != "vscode" ]; then #after tmux 3.2 version
#    pfetch #run pfetch if not in tmux or vscode
#  figlet -t "Hello There!" | lolcat #run if not in tmux or vscode
#  cat ~/welcome.txt #run if not in tmux or vscode
fi

#add scripts and appimages path to binaries path
if [ -d "$HOME/.local/bin" ] ; then
  PATH="$PATH:$HOME/.local/bin/scripts/"
  PATH="$PATH:$HOME/.local/bin/appImages"
  PATH="$PATH:$HOME/.local/bin"
fi

#add volta env vars
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"


#add Go
export PATH=$PATH:/usr/local/go/bin

#add Go binaries installed with go install
export PATH="$PATH:$HOME/go/bin/"

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    #alias fgrep='fgrep --color=auto'
    #alias egrep='egrep --color=auto'
fi
# some more ls aliases
alias ll='ls -l'
alias la='ls -A'

##Only works with newer versions of lf
LFCD="$HOME/.local/bin/scripts/lfcd.sh"
if [ -f "$LFCD" ]; then
    source "$LFCD"
fi

export EDITOR=nvim
export VISUAL="$EDITOR"

## source session vars for home-manager
. "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"


if [ -f ~/.config/starship/starship.toml ]; then
	eval "$(starship init zsh)"
	export STARSHIP_CONFIG=~/.config/starship/starship.toml
else
   eval "$(oh-my-posh init zsh --config ~/dotfiles/posh-themes/custom-nightowl.omp.json)"
fi

## activate Fast Node Manager
if command -v fnm >/dev/null 2>&1; then
    eval "$(fnm env --use-on-cd --shell zsh)"
fi

## Added by nala install completion command
# autoload -Uz compinit
# zstyle ':completion:*' menu select
# fpath+=~/.zfunc

# bun completions
[ -s "/home/cipo/.bun/_bun" ] && source "/home/cipo/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# ssh agent
export SSH_AUTH_SOCK="${XDG_RUNTIME_DIR}/ssh-agent.socket"
