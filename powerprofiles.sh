#!/bin/bash

status=$(powerprofilesctl get)

if [ "$status" == "power-saver" ]; then
    powerprofilesctl set balanced
    status="AHORRO DE ENERGIA"
elif [ "$status" == "balanced" ]; then
    powerprofilesctl set performance
    status="BALANCED"
else
    powerprofilesctl set power-saver
    status="PERFORMANCE"
fi 

notify-send "El modo $status ha sido activado" --app-name=System
