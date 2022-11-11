#!/bin/bash
# ---------------------------------------------------
# Overwrite xinitrc
rm -rf ~/.config/chromium/Singleton*
rm  /home/jean/.xinitrc
cp config_files/.xinitrc /home/jean/.xinitrc
systemctl restart localui
systemctl restart lcd 
