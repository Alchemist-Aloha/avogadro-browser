#!/bin/bash

# Start Avogadro in the background
/usr/bin/avogadro &

# Save the PID
AVOGADRO_PID=$!

# Wait for the window to appear
# We check for a window named "Avogadro"
while ! wmctrl -l | grep -i "Avogadro"; do
    # Check if the process is still running
    if ! kill -0 $AVOGADRO_PID 2>/dev/null; then
        echo "Avogadro failed to start"
        exit 1
    fi
    sleep 0.5
done

# Maximize the window
wmctrl -r "Avogadro" -b add,maximized_vert,maximized_horz

# Wait for Avogadro to exit
wait $AVOGADRO_PID
