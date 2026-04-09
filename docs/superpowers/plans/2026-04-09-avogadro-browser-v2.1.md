# Avogadro 1.2 Browser V2.1 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Improve Avogadro window sizing and responsiveness by adding a window manager (Openbox) and an automated maximization script.

**Architecture:** We will add `openbox` and `wmctrl` to the Docker image. A new startup script `start-avogadro.sh` will launch Avogadro and then use `wmctrl` to maximize it. TigerVNC will be updated to default to a higher resolution (1920x1080).

**Tech Stack:** Docker, TigerVNC, Openbox, wmctrl, bash.

---

### Task 1: Update Dockerfile with Window Manager

**Files:**
- Modify: `Dockerfile`

- [ ] **Step 1: Add `openbox` and `wmctrl` to the dependency list**

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

# Set workdir
WORKDIR /root

# Expose noVNC port
EXPOSE 6080

COPY index.html /opt/noVNC/index.html

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
```

- [ ] **Step 2: Commit**

```bash
git add Dockerfile
git commit -m "feat: add openbox and wmctrl to Dockerfile"
```

---

### Task 2: Create Maximization Startup Script

**Files:**
- Create: `start-avogadro.sh`

- [ ] **Step 1: Create `start-avogadro.sh`**

```bash
#!/bin/bash

# Start Avogadro in the background
/usr/bin/avogadro &

# Wait for the window to appear
# We check for a window named "Avogadro"
while ! wmctrl -l | grep -i "Avogadro"; do
    sleep 0.5
done

# Maximize the window
wmctrl -r "Avogadro" -b add,maximized_vert,maximized_horz
```

- [ ] **Step 2: Commit**

```bash
chmod +x start-avogadro.sh
git add start-avogadro.sh
git commit -m "feat: add start-avogadro script to handle maximization"
```

---

### Task 3: Update supervisord.conf for Openbox and Script

**Files:**
- Modify: `supervisord.conf`

- [ ] **Step 1: Update TigerVNC resolution and add Openbox program**

```ini
[supervisord]
nodaemon=true
user=root

[program:tigervnc]
# Set default geometry to 1920x1080
command=/usr/bin/Xtigervnc :1 -desktop Avogadro -rfbport 5900 -SecurityTypes None -AlwaysShared -AcceptKeyEvents -AcceptPointerEvents -AcceptSetDesktopSize -geometry 1920x1080 -depth 24
autorestart=true

[program:openbox]
command=/usr/bin/openbox --display :1
autorestart=true
depends_on=tigervnc

[program:novnc]
command=/opt/noVNC/utils/novnc_proxy --vnc localhost:5900 --listen 6080 --web /opt/noVNC
autorestart=true
depends_on=tigervnc

[program:avogadro]
# Use the new startup script
command=/usr/local/bin/start-avogadro.sh
environment=DISPLAY=":1"
autorestart=false
depends_on=openbox
```

- [ ] **Step 2: Commit**

```bash
git add supervisord.conf
git commit -m "feat: update supervisord to use openbox and start-avogadro script"
```

---

### Task 4: Final Verification

- [ ] **Step 1: Rebuild and run the container**

Run: `docker compose build && docker compose up -d`

- [ ] **Step 2: Verify Avogadro is maximized**

Visit: `http://localhost:6080/`
Expected: Avogadro opens automatically, fills the screen (1920x1080), and resizes if the browser window changes.
