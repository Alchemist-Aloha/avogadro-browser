# Design Document: Avogadro 1.2 Browser V2 (Dynamic & GPU-Accelerated)

## Overview
This upgrade improves the `avogadro-browser` by adding dynamic resolution matching, auto-connecting web interface, hardware-accelerated 3D rendering (GPU), and automated CI/CD via GitHub Actions.

## Architecture Changes
- **VNC Server:** Replaced `Xvfb` + `x11vnc` with `TigerVNC` (`Xtigervnc`) to support the `RandR` extension for dynamic remote resizing.
- **Display Resolution:** The `noVNC` client will be configured to request a remote resize (`resize=remote`) to match the user's browser window.
- **Web Interface:** A root redirect will be added so that `http://localhost:6080/` automatically connects to the VNC session.
- **GPU Acceleration:**
  - **Mesa DRI:** Installed for standard Intel/AMD hardware.
  - **NVIDIA:** Support for the `nvidia-container-toolkit`.
  - **VirtualGL:** (Optional/Future) To bridge hardware rendering to the X server.
- **CI/CD:** GitHub Actions workflow for building and pushing the Docker image to GitHub Container Registry (GHCR).

## Component Configuration

### supervisord.conf (v2)
- **[program:tigervnc]**: Launches `Xtigervnc` on display `:1` with `RandR` enabled.
- **[program:novnc]**: Runs `websockify` with a custom `index.html` or a redirect script.
- **[program:avogadro]**: Launches `avogadro` on display `:1`.

### Dockerfile (v2)
- Installs `tigervnc-standalone-server`, `tigervnc-xorg-extension`, `libgl1-mesa-dri`, `libglu1-mesa`.
- Sets up a default `noVNC` configuration that enables autoconnect.

## GPU Passthrough Strategy
- **Intel/AMD:** Mount `/dev/dri` as a device in Docker.
- **NVIDIA:** Use the `nvidia` runtime and set `NVIDIA_DRIVER_CAPABILITIES=all`.

## GitHub Actions Workflow
- **Trigger:** On push to `master` or on pull requests.
- **Build:** Uses `docker/build-push-action` to build for `amd64`.
- **Registry:** Pushes to `ghcr.io/${{ github.repository }}:latest`.

## Success Criteria
1. Container starts and serves the VNC client at the root URL.
2. The VNC session resizes automatically when the browser window is resized.
3. 3D rendering in Avogadro remains smooth, with hardware acceleration when a GPU is provided.
4. Molecule files are persisted in the `molecules` volume.
5. GitHub Action successfully builds the image on every push.
