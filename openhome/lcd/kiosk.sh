#!/bin/bash

xset s noblank
xset s off
xset -dpms

unclutter -idle 0.5 -root &

sed -i 's/"exited_cleanly":false/"exited_cleanly":true/' /home/jean/.config/chromium/Default/Preferences
sed -i 's/"exit_type":"Crashed"/"exit_type":"Normal"/' /home/jean/.config/chromium/Default/Preferences

#chromium --noerrdialogs --disable-infobars --kiosk "http://127.0.0.1:4150/ap-display"&
chromium --display=:0 --kiosk --incognito --window-position=0,0 --app="http://127.0.0.1:4150/ap-display"
#chromium  --noerrdialogs --disable-infobars --app="http://127.0.0.1:4150/ap-display"&


while true; do
   xdotool keydown ctrl+Tab; xdotool keyup ctrl+Tab;
   sleep 10
done

