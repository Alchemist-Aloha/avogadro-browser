# Avogadro 1.2 Browser Kiosk Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Remove window decorations (title bars and borders) from all windows in the Avogadro VNC session to prevent accidental closing.

**Architecture:** We will create a custom Openbox configuration file (`rc.xml`) that disables decorations for all applications and copy it to the container's system-wide configuration directory.

**Tech Stack:** Docker, Openbox, XML.

---

### Task 1: Create Openbox Kiosk Configuration

**Files:**
- Create: `rc.xml`

- [ ] **Step 1: Create `rc.xml` with decoration-disabling rules**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<openbox_config xmlns="http://openbox.org/3.4/rc" xmlns:xi="http://www.w3.org/2001/XInclude">
  <applications>
    <application class="*">
      <decor>no</decor>
      <maximized>yes</maximized>
    </application>
  </applications>
</openbox_config>
```

- [ ] **Step 2: Commit**

```bash
git add rc.xml
git commit -m "feat: add kiosk-mode rc.xml for Openbox"
```

---

### Task 2: Update Dockerfile to include Kiosk Config

**Files:**
- Modify: `Dockerfile`

- [ ] **Step 1: Update `Dockerfile` to copy `rc.xml` to the system-wide Openbox config path**

```dockerfile
# (Around the config copy section)
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY start-avogadro.sh /usr/local/bin/start-avogadro.sh
RUN chmod +x /usr/local/bin/start-avogadro.sh

# Add kiosk config for Openbox
COPY rc.xml /etc/xdg/openbox/rc.xml
```

- [ ] **Step 2: Commit**

```bash
git add Dockerfile
git commit -m "feat: update Dockerfile to include Openbox kiosk config"
```

---

### Task 3: Final Verification

- [ ] **Step 1: Rebuild and run the container**

Run: `docker compose build && docker compose up -d`

- [ ] **Step 2: Verify windows are undecorated**

Visit: `http://localhost:6080/`
Expected: Avogadro opens maximized with **no title bar**.
