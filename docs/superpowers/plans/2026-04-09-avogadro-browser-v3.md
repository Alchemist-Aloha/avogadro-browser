# Avogadro Browser Multi-Target Build Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement automated builds for CPU, General GPU, and NVIDIA targets using targeted Dockerfiles and a GitHub Actions matrix.

**Architecture:** Create three separate Dockerfiles (`Dockerfile.cpu`, `Dockerfile.gpu`, `Dockerfile.nvidia`) and update the GitHub Actions workflow to build and push these variants to GHCR.

**Tech Stack:** Docker, GitHub Actions, Ubuntu 18.04, NVIDIA OpenGL Runtime.

---

### Task 1: Create Targeted Dockerfiles

**Files:**
- Create: `Dockerfile.cpu`
- Create: `Dockerfile.gpu`
- Create: `Dockerfile.nvidia`
- Modify: `Dockerfile`

- [ ] **Step 1: Create `Dockerfile.cpu` (Software Rendering)**

```dockerfile
FROM ubuntu:18.04

# Prevent interactive prompts during build
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies (Minimal software rendering)
RUN apt-get update && apt-get install -y \
    avogadro \
    tigervnc-standalone-server \
    tigervnc-common \
    supervisor \
    git \
    python3 \
    python3-numpy \
    net-tools \
    libgl1-mesa-glx \
    libglu1-mesa \
    openbox \
    wmctrl \
    && rm -rf /var/lib/apt/lists/*

# Install noVNC and websockify
RUN git clone https://github.com/novnc/noVNC.git /opt/noVNC \
    && git clone https://github.com/novnc/websockify.git /opt/noVNC/utils/websockify

# Setup configurations
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY start-avogadro.sh /usr/local/bin/start-avogadro.sh
RUN chmod +x /usr/local/bin/start-avogadro.sh

# Add kiosk config for Openbox
COPY rc.xml /etc/xdg/openbox/rc.xml

# Set workdir
WORKDIR /root

# Expose noVNC port
EXPOSE 6080

COPY index.html /opt/noVNC/index.html

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
```

- [ ] **Step 2: Create `Dockerfile.gpu` (General GPU - Mesa DRI)**

```dockerfile
FROM ubuntu:18.04

# Prevent interactive prompts during build
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies (Including Mesa DRI for Intel/AMD)
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
    openbox \
    wmctrl \
    && rm -rf /var/lib/apt/lists/*

# Install noVNC and websockify
RUN git clone https://github.com/novnc/noVNC.git /opt/noVNC \
    && git clone https://github.com/novnc/websockify.git /opt/noVNC/utils/websockify

# Setup configurations
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY start-avogadro.sh /usr/local/bin/start-avogadro.sh
RUN chmod +x /usr/local/bin/start-avogadro.sh

# Add kiosk config for Openbox
COPY rc.xml /etc/xdg/openbox/rc.xml

# Set workdir
WORKDIR /root

# Expose noVNC port
EXPOSE 6080

COPY index.html /opt/noVNC/index.html

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
```

- [ ] **Step 3: Create `Dockerfile.nvidia` (NVIDIA Native)**

```dockerfile
FROM nvidia/opengl:1.2-glvnd-runtime-ubuntu18.04

# Prevent interactive prompts during build
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies (NVIDIA base already has GL libraries)
RUN apt-get update && apt-get install -y \
    avogadro \
    tigervnc-standalone-server \
    tigervnc-common \
    supervisor \
    git \
    python3 \
    python3-numpy \
    net-tools \
    openbox \
    wmctrl \
    && rm -rf /var/lib/apt/lists/*

# Install noVNC and websockify
RUN git clone https://github.com/novnc/noVNC.git /opt/noVNC \
    && git clone https://github.com/novnc/websockify.git /opt/noVNC/utils/websockify

# Setup configurations
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY start-avogadro.sh /usr/local/bin/start-avogadro.sh
RUN chmod +x /usr/local/bin/start-avogadro.sh

# Add kiosk config for Openbox
COPY rc.xml /etc/xdg/openbox/rc.xml

# Set workdir
WORKDIR /root

# Expose noVNC port
EXPOSE 6080

COPY index.html /opt/noVNC/index.html

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
```

- [ ] **Step 4: Commit new Dockerfiles**

```bash
git add Dockerfile.cpu Dockerfile.gpu Dockerfile.nvidia
git commit -m "feat: add targeted Dockerfiles for CPU, GPU, and NVIDIA"
```

---

### Task 2: Update GitHub Actions for Matrix Build

**Files:**
- Modify: `.github/workflows/docker-build.yml`

- [ ] **Step 1: Implement Matrix Build in GHA**

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
    strategy:
      matrix:
        target: [cpu, gpu, nvidia]
    permissions:
      contents: read
      packages: write
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Log in to GitHub Container Registry
        uses: docker/login-action@v2
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v2

      - name: Build and push image
        uses: docker/build-push-action@v4
        with:
          context: .
          file: ./Dockerfile.${{ matrix.target }}
          push: ${{ github.event_name != 'pull_request' }}
          tags: |
            ghcr.io/${{ github.repository }}:${{ matrix.target }}
          cache-from: type=gha,scope=${{ matrix.target }}
          cache-to: type=gha,mode=max,scope=${{ matrix.target }}
```

- [ ] **Step 2: Commit GHA update**

```bash
git add .github/workflows/docker-build.yml
git commit -m "feat: implement GitHub Actions matrix build for multi-target images"
```

---

### Task 3: Cleanup and Documentation

**Files:**
- Modify: `README.md`
- Remove: `Dockerfile`

- [ ] **Step 1: Update `README.md` with new tag information**

```markdown
# Avogadro 1.2 Browser V3

## Available Images
- `ghcr.io/<repo>:cpu` - Optimized for software rendering (no GPU required).
- `ghcr.io/<repo>:gpu` - Recommended for Intel/AMD hardware (uses Mesa DRI).
- `ghcr.io/<repo>:nvidia` - Recommended for NVIDIA hardware (requires nvidia-container-toolkit).

## Usage
Select the image that matches your hardware:
```bash
# For Intel/AMD
docker run -d -p 6080:6080 --device /dev/dri:/dev/dri ghcr.io/<repo>:gpu
```

- [ ] **Step 2: Remove legacy `Dockerfile`**

```bash
git rm Dockerfile
```

- [ ] **Step 3: Final Commit**

```bash
git add README.md
git commit -m "docs: update README with multi-target image tags"
```
