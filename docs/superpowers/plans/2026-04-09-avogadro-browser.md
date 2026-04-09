# Avogadro 1.2 Browser Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create a Docker-based environment to run legacy Avogadro 1.2 and access it via a web browser using noVNC.

**Architecture:** A single Docker container running Ubuntu 18.04, Xvfb for a virtual display, x11vnc for VNC access, and noVNC with websockify for browser-based VNC. Supervisord will manage these processes.

**Tech Stack:** Docker, Ubuntu 18.04, Avogadro 1.2, Xvfb, x11vnc, noVNC, Supervisord.

---

### Task 1: Project Scaffolding & Dependencies

**Files:**
- Create: `supervisord.conf`
- Create: `entrypoint.sh`

- [ ] **Step 1: Create `supervisord.conf` to manage background processes**

```ini
[supervisord]
nodaemon=true
user=root

[program:xvfb]
command=/usr/bin/Xvfb :1 -screen 0 1280x1024x24
autorestart=true

[program:x11vnc]
command=/usr/bin/x11vnc -display :1 -nopw -forever -shared
autorestart=true
depends_on=xvfb

[program:novnc]
command=/opt/noVNC/utils/launch.sh --vnc localhost:5900 --listen 6080
autorestart=true
depends_on=x11vnc

[program:avogadro]
command=/usr/bin/avogadro
environment=DISPLAY=":1"
autorestart=true
depends_on=xvfb
```

- [ ] **Step 2: Create `entrypoint.sh` for environment setup**

```bash
#!/bin/bash
export DISPLAY=:1
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
```

- [ ] **Step 3: Make `entrypoint.sh` executable**

Run: `chmod +x entrypoint.sh`

- [ ] **Step 4: Commit**

```bash
git add supervisord.conf entrypoint.sh
git commit -m "feat: add supervisor config and entrypoint script"
```

---

### Task 2: Dockerfile Implementation

**Files:**
- Create: `Dockerfile`

- [ ] **Step 1: Write the `Dockerfile`**

```dockerfile
FROM ubuntu:18.04

# Prevent interactive prompts during build
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y \
    avogadro \
    xvfb \
    x11vnc \
    supervisor \
    git \
    python-numpy \
    net-tools \
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

- [ ] **Step 2: Build the Docker image**

Run: `docker build -t avogadro-browser .`
Expected: Successful build (this may take a few minutes).

- [ ] **Step 3: Commit**

```bash
git add Dockerfile
git commit -m "feat: add Dockerfile for avogadro-browser"
```

---

### Task 3: Orchestration & Volume Persistence

**Files:**
- Create: `docker-compose.yml`

- [ ] **Step 1: Create `docker-compose.yml`**

```yaml
version: '3'
services:
  avogadro:
    build: .
    image: avogadro-browser
    ports:
      - "6080:6080"
    volumes:
      - ./molecules:/root/molecules
    restart: always
```

- [ ] **Step 2: Create the `molecules` directory for persistence**

Run: `mkdir molecules`

- [ ] **Step 3: Run the container with docker-compose**

Run: `docker-compose up -d`
Expected: Container starts successfully.

- [ ] **Step 4: Verify web access**

Visit: `http://localhost:6080/vnc.html` in your browser.
Expected: noVNC interface appears, click "Connect", and Avogadro 1.2 should be visible.

- [ ] **Step 5: Commit**

```bash
git add docker-compose.yml
git commit -m "feat: add docker-compose for orchestration and persistence"
```

---

### Task 4: Documentation & Cleanup

**Files:**
- Create: `README.md`

- [ ] **Step 1: Create `README.md` with usage instructions**

```markdown
# Avogadro 1.2 Browser

Run legacy Avogadro 1.2 in a Docker container and access it via your web browser.

## Quick Start
1. Ensure Docker and Docker Compose are installed.
2. Run `docker-compose up -d`.
3. Open your browser to `http://localhost:6080/vnc.html`.
4. Click "Connect".

## Persistence
Save your molecule files in the `/root/molecules` directory inside the container to persist them in the local `./molecules` folder.
```

- [ ] **Step 2: Commit**

```bash
git add README.md
git commit -m "docs: add README with usage instructions"
```
