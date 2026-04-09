#!/bin/bash

# Start Avogadro in the background
/usr/bin/avogadro &

# Wait for the window to appear
# We check for a window named "Avogadro"
while ! wmctrl -l | grep -i "Avogadro"; do
    sleep 0.5
done

# Maximize the window
wmctrl -r "Avogadro" -b add,maximized_vert,maximized_horz
