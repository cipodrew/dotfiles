alias fd='fdfind'
#alias updateall='flatpak update && echo "" && echo "now running nala" | lolcat && sudo nala update'
alias updateall='flatpak update && echo "" && figlet "nala" | lolcat && sudo nala update'
alias clipcp='xclip -selection c'
alias v="nvim"
alias bat="batcat"
alias tx="tmux new -s 'default'"
alias trackmanuallyinstalled="appImgFileUpdate.sh && fontFileUpdate.sh && flatpakFileUpdate.sh && nalaFileUpdate.sh"
alias lla="ls -lA"
# alias l="ls -A"
alias l="nnn"

alias pomowo="pomodoro.sh 'work'"
alias pomobr="pomodoro.sh 'break'"
