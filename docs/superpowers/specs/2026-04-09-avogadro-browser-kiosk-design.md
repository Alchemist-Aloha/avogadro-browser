# Design Document: Avogadro 1.2 Browser Kiosk (Undecorated Windows)

## Overview
This update improves the `avogadro-browser` by removing window decorations (title bars and borders) from all windows, creating a "kiosk" mode that prevents accidental closing or manipulation of the application.

## Architecture Changes
- **Window Decoration:** Configured `openbox` to disable decorations for all windows.
- **Configuration Management:** Introduced a custom `rc.xml` for Openbox, placed in the system-wide configuration directory (`/etc/xdg/openbox/`).
- **Persistence:** Existing maximization logic (`start-avogadro.sh`) is retained to ensure the application fills the screen.

## Component Configuration

### rc.xml (Kiosk)
- A minimal Openbox configuration that sets:
  - `<decor>no</decor>` for all application classes (`*`).
  - Optionally `<maximized>yes</maximized>` as a fallback to the `wmctrl` script.

### Dockerfile (Kiosk Update)
- Adds a `COPY` step for `rc.xml` to `/etc/xdg/openbox/rc.xml`.

### supervisord.conf
- No changes needed to the process management.

## Success Criteria
1. Container starts and automatically connects at `http://localhost:6080/`.
2. Avogadro 1.2 starts maximized and **without a title bar** (no close/minimize/maximize buttons visible).
3. All other windows (dialogs, file pickers) also appear without decorations.
4. Resizing the browser window continues to resize the remote desktop and the Avogadro window.
