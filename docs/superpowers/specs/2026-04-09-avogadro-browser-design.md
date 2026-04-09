# Design Document: Avogadro 1.2 Browser Access via Docker

## Overview
This project provides a Docker-based environment for running legacy Avogadro 1.2 on Linux and accessing its GUI through a web browser using noVNC. This is achieved by combining a virtual X server (Xvfb), a VNC server (x11vnc), and a VNC-to-WebSocket bridge (noVNC/websockify).

## Architecture
- **Base OS:** Ubuntu 18.04 (LTS) - selected for its native support of Avogadro 1.2 in its repositories.
- **Rendering:** Mesa LLVMpipe for software-based OpenGL (CPU-only).
- **Display Server:** Xvfb (X Virtual Framebuffer) - creates a virtual display without physical hardware.
- **Remote Access:**
  - **x11vnc:** Provides VNC access to the Xvfb display.
  - **noVNC:** A JavaScript VNC client for browser access.
  - **websockify:** Bridges VNC TCP traffic to WebSockets for noVNC.
- **Process Management:** Supervisord - ensures all background processes (Xvfb, x11vnc, websockify, Avogadro) start and stay running.

## Project Structure
```text
/home/likun/avogadro-browser/
├── Dockerfile           # Builds the Ubuntu 18.04 image with all dependencies
├── supervisord.conf      # Configuration for all background services
├── entrypoint.sh         # Initialization script for the container
└── docker-compose.yml    # Local deployment orchestration
```

## Detailed Component Config

### Dockerfile
- Installs `avogadro`, `xvfb`, `x11vnc`, `python-numpy`, `net-tools`.
- Clones `noVNC` and `websockify` from GitHub.
- Sets up a non-root user for security.

### supervisord.conf
- **[program:xvfb]**: Starts Xvfb on display `:1` with 1280x1024x24 resolution.
- **[program:x11vnc]**: Attaches to `:1` on port 5900 with no password (default for local dev).
- **[program:novnc]**: Runs `websockify` on port 6080, serving noVNC static files.
- **[program:avogadro]**: Launches `avogadro` on display `:1`.

### entrypoint.sh
- Sets up display environment variables.
- Launches `supervisord` in the foreground.

## Persistence
A Docker volume will be mapped to `/home/avogadro/molecules` to allow users to save and load `.cml`, `.pdb`, and other molecular files across container restarts.

## Success Criteria
1. `docker-compose up` completes without errors.
2. `http://localhost:6080/vnc.html` loads the noVNC interface.
3. Avogadro 1.2 is visible and interactive.
4. 3D molecular structures render correctly (tested with software OpenGL).
