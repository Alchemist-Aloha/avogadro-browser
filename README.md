# Avogadro 1.2 Browser V3

Run legacy Avogadro 1.2 in a Docker container and access it via your web browser.

## Available Images
- `ghcr.io/alchemist-aloha/avogadro-browser:cpu` - Optimized for software rendering (no GPU required).
- `ghcr.io/alchemist-aloha/avogadro-browser:gpu` - Recommended for Intel/AMD hardware (uses Mesa DRI).
- `ghcr.io/alchemist-aloha/avogadro-browser:nvidia` - Recommended for NVIDIA hardware (requires nvidia-container-toolkit).

## Quick Start
1. Ensure Docker and Docker Compose are installed.
2. Select the image that matches your hardware.
3. Run with `docker run` or update `docker-compose.yml`.
4. Open your browser to `http://localhost:6080/`.
5. It should automatically connect to the Avogadro VNC.

## Usage

### CPU only
```bash
docker run -d -p 6080:6080 --device /dev/dri:/dev/dri ghcr.io/alchemist-aloha/avogadro-browser:cpu
```

### Intel/AMD GPU
```bash
docker run -d -p 6080:6080 --device /dev/dri:/dev/dri ghcr.io/alchemist-aloha/avogadro-browser:gpu
```
### NVIDIA GPU
```bash
docker run -d -p 6080:6080 --gpus all -e NVIDIA_VISIBLE_DEVICES=all ghcr.io/alchemist-aloha/avogadro-browser:nvidia
```
Ensure `nvidia-container-toolkit` is installed on your host.

## Persistence
Save your molecule files in the `/root/molecules` directory inside the container to persist them in the local `./molecules` folder.
