#!/bin/bash
#from bashbunni github gist discussion

declare -A pomo_options
pomo_options["work"]="45"
pomo_options["break"]="10"

pomodoro () {
  if [ -n "$1" -a -n "${pomo_options["$1"]}" ]; then
    val=$1
    if [ -z "$2" ]; then
      minutes=${pomo_options["$val"]}
    else
      minutes=$2
    fi
    #echo $val | lolcat
    #timer $minutes"m"
    timer -n $val $minutes"m"
    notify-send -t 0 "$val session done" 
    pw-play --volume=0.5 /usr/share/sounds/freedesktop/stereo/message.oga #pipewire
    #paplay /usr/share/sounds/freedesktop/stereo/message.oga #pulseaudio
  else
    echo "Usage: pomodoro <work|break> [minutes]"
  fi
}

if [ "$1" == "work" ]; then
  pomodoro "work" "$2"
elif [ "$1" == "break" ]; then
  pomodoro "break" "$2"
else
  echo "Usage: ./timer.sh <work|break> [minutes]"
fi

#Make sure to install https://github.com/caarlos0/timer
#And make sure to have lolcat installed```

