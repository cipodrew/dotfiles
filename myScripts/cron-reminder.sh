#!/bin/bash

# It should be run with the following user crontab job (crontab -e)
# */60 * * * * ~/.local/bin/scripts/cron-reminder.sh >/dev/null 2>&1
## Make sure the file is executable and the path is correct!

export DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus;
export DISPLAY=:0;
export XDG_RUNTIME_DIR=/run/user/1000
/usr/bin/notify-send -t 10000 -i "~/.local/bin/scripts/glass_water.jpg" " hydration check" "60 min passati" 
/usr/bin/pw-play --volume=0.3 /usr/share/sounds/freedesktop/stereo/message.oga #pipewire
#paplay /usr/share/sounds/freedesktop/stereo/message.oga #pulseaudio
