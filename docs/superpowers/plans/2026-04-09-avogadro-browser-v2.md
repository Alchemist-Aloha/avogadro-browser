# Avogadro 1.2 Browser V2 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Upgrade `avogadro-browser` to support dynamic resolution matching, auto-connect, hardware acceleration (GPU), and automated CI/CD.

**Architecture:** Replacing `Xvfb`+`x11vnc` with `TigerVNC` for `RandR` support (dynamic resizing). Modifying the entrypoint and web setup to facilitate auto-connection and GPU detection. Adding a GitHub Actions workflow for image building.

**Tech Stack:** Docker, TigerVNC, noVNC, Ubuntu 18.04, GitHub Actions.

---

### Task 1: Update Dependencies & Base Image

**Files:**
- Modify: `Dockerfile`

- [ ] **Step 1: Update `Dockerfile` to include TigerVNC and DRI libraries**

```dockerfile
FROM ubuntu:18.04

# Prevent interactive prompts during build
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y \
    avogadro \
    tigervnc-standalone-server \
    tigervnc-common \
    supervisor \
    git \
    python3 \
    python3-numpy \
    net-tools \
    libgl1-mesa-dri \
    libglu1-mesa \
    && rm -rf /var/lib/apt/lists/*

# Install noVNC and websockify
RUN git clone https://github.com/novnc/noVNC.git /opt/noVNC \
    && git clone https://github.com/novnc/websockify.git /opt/noVNC/utils/websockify

# Setup configurations
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

# Set workdir
WORKDIR /root

# Expose noVNC port
EXPOSE 6080

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
```

- [ ] **Step 2: Commit**

```bash
git add Dockerfile
git commit -m "feat: upgrade dependencies to TigerVNC and DRI libs"
```

---

### Task 2: Configure TigerVNC for Dynamic Resizing

**Files:**
- Modify: `supervisord.conf`

- [ ] **Step 1: Replace Xvfb/x11vnc with TigerVNC in `supervisord.conf`**

```ini
[supervisord]
nodaemon=true
user=root

[program:tigervnc]
command=/usr/bin/Xtigervnc :1 -desktop Avogadro -rfbport 5900 -SecurityTypes None -AlwaysShared -AcceptKeyEvents -AcceptPointerEvents -AcceptSetDesktopSize -geometry 1280x1024 -depth 24
autorestart=true

[program:novnc]
# resize=remote enables dynamic resizing from the browser side
command=/opt/noVNC/utils/novnc_proxy --vnc localhost:5900 --listen 6080 --web /opt/noVNC
autorestart=true
depends_on=tigervnc

[program:avogadro]
command=/usr/bin/avogadro
environment=DISPLAY=":1"
autorestart=true
depends_on=tigervnc
```

- [ ] **Step 2: Commit**

```bash
git add supervisord.conf
git commit -m "feat: switch to TigerVNC for dynamic resizing support"
```

---

### Task 3: Implement Auto-Connect Redirect

**Files:**
- Create: `index.html`
- Modify: `Dockerfile`

- [ ] **Step 1: Create an `index.html` to redirect to the VNC client with autoconnect**

```html
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="refresh" content="0; url=vnc.html?autoconnect=true&resize=remote">
    </head>
    <body>
        <p>Redirecting to <a href="vnc.html?autoconnect=true&resize=remote">Avogadro VNC</a>...</p>
    </body>
</html>
```

- [ ] **Step 2: Update `Dockerfile` to copy `index.html` into noVNC directory**

Insert before `ENTRYPOINT`:
```dockerfile
COPY index.html /opt/noVNC/index.html
```

- [ ] **Step 3: Commit**

```bash
git add index.html Dockerfile
git commit -m "feat: add root redirect to vnc.html with autoconnect"
```

---

### Task 4: GPU Passthrough & Compose Refinement

**Files:**
- Modify: `docker-compose.yml`

- [ ] **Step 1: Update `docker-compose.yml` with GPU examples and remove obsolete version**

```yaml
services:
  avogadro:
    build: .
    image: avogadro-browser
    ports:
      - "6080:6080"
    volumes:
      - ./molecules:/root/molecules
    # Uncomment for Intel/AMD GPU
    # devices:
    #   - /dev/dri:/dev/dri
    # Uncomment for NVIDIA GPU
    # deploy:
    #   resources:
    #     reservations:
    #       devices:
    #         - driver: nvidia
    #           count: 1
    #           capabilities: [gpu]
    restart: always
```

- [ ] **Step 2: Commit**

```bash
git add docker-compose.yml
git commit -m "feat: add GPU passthrough examples to docker-compose"
```

---

### Task 5: GitHub Actions CI

**Files:**
- Create: `.github/workflows/docker-build.yml`

- [ ] **Step 1: Create the GitHub Action workflow**

```yaml
name: Docker Build and Push

on:
  push:
    branches: [ master ]
  pull_request:
    branches: [ master ]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v2

      - name: Build image
        uses: docker/build-push-action@v4
        with:
          context: .
          push: false
          tags: avogadro-browser:latest
          cache-from: type=gha
          cache-to: type=gha,mode=max
```

- [ ] **Step 2: Commit**

```bash
mkdir -p .github/workflows
git add .github/workflows/docker-build.yml
git commit -m "feat: add GitHub Action for Docker build"
```

---

### Task 6: Documentation Update

**Files:**
- Modify: `README.md`

- [ ] **Step 1: Update `README.md` with V2 features**

```markdown
# Avogadro 1.2 Browser V2

## New Features
- **Dynamic Resizing:** The remote desktop now resizes to match your browser window automatically.
- **Auto-Connect:** Accessing the root URL now connects you directly.
- **Hardware Acceleration:** Supports GPU passthrough for better performance.

## GPU Usage

### Intel/AMD
Uncomment the `devices` section in `docker-compose.yml`.

### NVIDIA
Uncomment the `deploy` section in `docker-compose.yml` and ensure `nvidia-container-toolkit` is installed on your host.
```

- [ ] **Step 2: Commit**

```bash
git add README.md
git commit -m "docs: update README for V2 and GPU instructions"
```
