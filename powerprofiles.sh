#!/bin/bash

status=$(powerprofilesctl get)

if [ "$status" == "power-saver" ]; then
    powerprofilesctl set balanced
    status="BALANCED"
elif [ "$status" == "balanced" ]; then
    powerprofilesctl set performance
    status="PERFORMANCE"
else
    powerprofilesctl set power-saver
    status="AHORRO DE ENERGIA"
fi 

notify-send "El modo $status ha sido activado" --app-name=System
