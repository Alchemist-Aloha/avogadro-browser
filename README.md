# Avogadro 1.2 Browser V2

Run legacy Avogadro 1.2 in a Docker container and access it via your web browser.

## New Features
- **Dynamic Resizing:** The remote desktop now resizes to match your browser window automatically.
- **Auto-Connect:** Accessing the root URL now connects you directly.
- **Hardware Acceleration:** Supports GPU passthrough for better performance.

## Quick Start
1. Ensure Docker and Docker Compose are installed.
2. Run `docker compose up -d`.
3. Open your browser to `http://localhost:6080/`.
4. It should automatically connect to the Avogadro VNC.

## GPU Usage

### Intel/AMD
Uncomment the `devices` section in `docker-compose.yml`.

### NVIDIA
Uncomment the `deploy` section in `docker-compose.yml` and ensure `nvidia-container-toolkit` is installed on your host.

## Persistence
Save your molecule files in the `/root/molecules` directory inside the container to persist them in the local `./molecules` folder.
