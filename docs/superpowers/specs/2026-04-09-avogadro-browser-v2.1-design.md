# Design Document: Avogadro 1.2 Browser V2.1 (Maximized & Auto-Resizing)

## Overview
This update improves the `avogadro-browser` by adding a window manager (Openbox) to ensure Avogadro starts maximized and responds correctly to browser window resizing.

## Architecture Changes
- **Window Management:** Added `openbox` to manage the Avogadro window.
- **Window Control:** Added `wmctrl` to programmatically maximize the Avogadro window on startup.
- **Startup Script:** Introduced `start-avogadro.sh` to coordinate the application launch and window maximization.
- **Resolution Tuning:** Updated the default TigerVNC resolution to 1920x1080 for better initial visual impact.

## Component Configuration

### supervisord.conf (v2.1)
- **[program:tigervnc]**: Launches `Xtigervnc` with `RandR` and `AcceptSetDesktopSize` enabled, defaulting to 1920x1080.
- **[program:openbox]**: Launches `openbox` to handle window decorations and resizing.
- **[program:avogadro]**: Launches `start-avogadro.sh` which starts Avogadro and then uses `wmctrl` to maximize it.

### start-avogadro.sh
- Starts `avogadro &`.
- Waits for the Avogadro window to appear (using a loop and `wmctrl -l`).
- Maximizes the window using `wmctrl -r "Avogadro" -b add,maximized_vert,maximized_horz`.

### Dockerfile (v2.1)
- Installs `openbox` and `wmctrl` via `apt-get`.
- Copies the new `start-avogadro.sh` script and makes it executable.

## Success Criteria
1. Container starts and automatically connects at `http://localhost:6080/`.
2. Avogadro 1.2 starts maximized to fill the initial 1920x1080 desktop.
3. When the browser window is resized, the remote desktop resizes, and Avogadro resizes with it.
4. The user experience is "seamless," with no manual window dragging or resizing required.
