FROM kasmweb/ubuntu-noble-nvidia-pytorch:1.18.0-rolling-daily

# =============================================================================
# NVIDIA GPU Configuration
# =============================================================================
# Enable GPU visibility and configure driver capabilities for compute, graphics, and display
ENV NVIDIA_VISIBLE_DEVICES=all \
    NVIDIA_DRIVER_CAPABILITIES=compute,utility,graphics,display \
    __GLX_VENDOR_LIBRARY_NAME=nvidia \
    __EGL_VENDOR_LIBRARY_FILENAMES=/usr/share/glvnd/egl_vendor.d/10_nvidia.json \
    VGL_DISPLAY=egl

USER root

# =============================================================================
# System Packages Installation
# =============================================================================
# Combine all apt operations into a single layer to minimize image size
RUN apt-get update && apt-get install -y --no-install-recommends \
    # OpenGL/EGL libraries for GPU rendering
    libgl1 \
    libgl1-mesa-dri \
    libegl1 \
    libgles2 \
    libglvnd0 \
    libglvnd-dev \
    # X11 libraries for GLX support
    libxau-dev \
    libxdmcp-dev \
    libxcb1-dev \
    libxext-dev \
    libx11-dev \
    libx11-xcb1 \
    # GPU testing and verification tools
    mesa-utils \
    mesa-utils-extra \
    vulkan-tools \
    glmark2 \
    # VirtualGL dependencies
    libxtst6 \
    libxv1 \
    libglu1-mesa \
    # Development tools and utilities
    lsb-release \
    apt-transport-https \
    curl \
    wget \
    libfreetype6-dev \
    pkg-config \
    gcc \
    less \
    software-properties-common \
    apt-utils \
    glances \
    htop \
    nano \
    sudo \
    # GNOME desktop environment
    gnome-session \
    gnome-shell \
    gnome-control-center \
    gnome-terminal \
    gnome-system-monitor \
    gnome-tweaks \
    # Additional utilities for AI CLI tools
    locales \
    neofetch \
    figlet \
    w3m-img \
    imagemagick \
    s3fs \
    socat \
    bubblewrap \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# =============================================================================
# NodeJS Installation (for AI CLI Tools)
# =============================================================================
# Install NodeJS 20.x for Claude Code, OpenAI Codex, and Gemini CLI
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get update && \
    apt-get install -y nodejs && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# =============================================================================
# NVIDIA EGL Configuration
# =============================================================================
# Configure libglvnd to route EGL calls to NVIDIA libraries
RUN mkdir -p /usr/share/glvnd/egl_vendor.d && \
    echo '{"file_format_version":"1.0.0","ICD":{"library_path":"libEGL_nvidia.so.0"}}' \
    > /usr/share/glvnd/egl_vendor.d/10_nvidia.json

# =============================================================================
# NVIDIA Library Path Configuration
# =============================================================================
# Add NVIDIA library paths to ld.so configuration
RUN echo '/usr/local/nvidia/lib' >> /etc/ld.so.conf.d/nvidia.conf && \
    echo '/usr/local/nvidia/lib64' >> /etc/ld.so.conf.d/nvidia.conf && \
    ldconfig

# =============================================================================
# GPU Utility Scripts
# =============================================================================
# Copy and configure VirtualGL wrapper and GPU verification scripts
COPY vglrun-wrapper.sh /usr/local/bin/vglrun-wrapper.sh
COPY verify-gpu.sh /usr/local/bin/verify-gpu.sh
RUN chmod +x /usr/local/bin/vglrun-wrapper.sh /usr/local/bin/verify-gpu.sh

# =============================================================================
# Go Language Installation
# =============================================================================
# Install Go for building GoCommands
RUN wget -q -c https://dl.google.com/go/go1.25.0.linux-amd64.tar.gz -O - | tar -xz -C /usr/local
ENV PATH=$PATH:/usr/local/go/bin

# =============================================================================
# CyVerse Integration
# =============================================================================
# Configure data-store directory for CSI driver mounts and install GoCommands
WORKDIR /home/kasm-user/data-store

RUN mkdir -p /home/kasm-user/.irods && \
    echo '{"irods_host": "data.cyverse.org", "irods_port": 1247, "irods_user_name": "$IPLANT_USER", "irods_zone_name": "iplant"}' | envsubst > /home/kasm-user/.irods/irods_environment.json

# Install GoCommands for CyVerse data management
RUN cd /usr/local/bin/ && \
    GOCMD_VER=$(curl -L -s https://raw.githubusercontent.com/cyverse/gocommands/main/VERSION.txt) && \
    curl -L -s https://github.com/cyverse/gocommands/releases/download/${GOCMD_VER}/gocmd-${GOCMD_VER}-linux-amd64.tar.gz | tar zxvf -

# =============================================================================
# User Configuration
# =============================================================================
# Configure sudo access for kasm-user
ARG LOCAL_USER=kasm-user
ARG PRIV_CMDS='ALL'

RUN usermod -aG sudo ${LOCAL_USER} && \
    echo "${LOCAL_USER} ALL=NOPASSWD: ${PRIV_CMDS}" >> /etc/sudoers

# =============================================================================
# VNC Configuration
# =============================================================================
# Copy KASM VNC configuration and startup scripts
COPY kasmvnc_defaults.yaml /usr/share/kasmvnc/kasmvnc_defaults.yaml
COPY vnc_startup.sh /dockerstartup/vnc_startup.sh
RUN chmod +x /dockerstartup/vnc_startup.sh

# Remove pyenv references from .bashrc to prevent startup errors
RUN sed -i '/pyenv/d' /home/kasm-user/.bashrc || true

# Create cache directory for conda with proper ownership
RUN mkdir -p /home/kasm-user/.cache && chown -R kasm-user:kasm-user /home/kasm-user/.cache

# =============================================================================
# Switch to kasm-user for User-Space Installations
# =============================================================================
USER kasm-user

# =============================================================================
# AI CLI Tools Installation
# =============================================================================
# Install Claude Code, OpenAI Codex, and Google Gemini CLI
RUN npm config set prefix /home/kasm-user/.npm-global && \
    export PATH=/home/kasm-user/.npm-global/bin:$PATH && \
    npm install -g @anthropic-ai/claude-code @google/gemini-cli @openai/codex

ENV PATH="/home/kasm-user/.npm-global/bin:${PATH}"

# =============================================================================
# Miniconda and Mamba Installation
# =============================================================================
# Install Miniconda package manager and mamba for faster dependency resolution
RUN curl -fsSL -o /tmp/Miniconda3-latest-Linux-x86_64.sh \
    https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh \
    && bash /tmp/Miniconda3-latest-Linux-x86_64.sh -b -p /home/kasm-user/miniconda3 \
    && rm /tmp/Miniconda3-latest-Linux-x86_64.sh \
    && /home/kasm-user/miniconda3/bin/conda init bash

ENV PATH="/home/kasm-user/miniconda3/bin:${PATH}"

# Install mamba using conda (use classic solver with no-plugins flag)
RUN /home/kasm-user/miniconda3/bin/conda --no-plugins install -y --solver=classic -c conda-forge mamba && \
    /home/kasm-user/miniconda3/bin/conda clean -afy

# =============================================================================
# Container Startup
# =============================================================================
ENTRYPOINT [ "/dockerstartup/vnc_startup.sh" ]
