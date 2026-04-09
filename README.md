# Avogadro 1.2 Browser

Run legacy Avogadro 1.2 in a Docker container and access it via your web browser.

## Quick Start
1. Ensure Docker and Docker Compose are installed.
2. Run `docker compose up -d`.
3. Open your browser to `http://localhost:6080/vnc.html`.
4. Click "Connect".

## Persistence
Save your molecule files in the `/root/molecules` directory inside the container to persist them in the local `./molecules` folder.
