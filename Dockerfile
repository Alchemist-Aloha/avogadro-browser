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
