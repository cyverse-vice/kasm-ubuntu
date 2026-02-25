FROM kasmweb/ubuntu-noble-desktop:1.17.0-rolling-daily

# create ~/data-store for CSI driver fuse mount
WORKDIR /home/kasm-user/data-store

# iRODS environment config for CyVerse Data Store
RUN mkdir -p /home/kasm-user/.irods && \
    echo '{"irods_host": "data.cyverse.org", "irods_port": 1247, "irods_user_name": "$IPLANT_USER", "irods_zone_name": "iplant"}' | envsubst > /home/kasm-user/.irods/irods_environment.json

USER root

# System packages (minimal) -- curl/wget needed at build time, disabled (chmod 000) in hardening layer
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl wget ca-certificates lsb-release less nano htop glances \
    # Python data science
    python3 python3-pip python3-venv python3-dev \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# GoCommands (static binary, no Go runtime needed)
RUN cd /usr/local/bin/ && \
    GOCMD_VER=$(curl -L -s https://raw.githubusercontent.com/cyverse/gocommands/main/VERSION.txt); \
    curl -L -s https://github.com/cyverse/gocommands/releases/download/${GOCMD_VER}/gocmd-${GOCMD_VER}-linux-amd64.tar.gz | tar zxvf -

# Python data science packages
RUN pip3 install --no-cache-dir --break-system-packages \
    pandas numpy scipy matplotlib seaborn scikit-learn

# VNC configuration (hardened)
COPY kasmvnc_defaults.yaml /usr/share/kasmvnc/kasmvnc_defaults.yaml
COPY vnc_startup.sh /dockerstartup/vnc_startup.sh
RUN chmod +x /dockerstartup/vnc_startup.sh

# ===== SECURITY HARDENING =====
# Purge sudo FIRST (while apt/dpkg are still executable)
RUN SUDO_FORCE_REMOVE=yes apt-get purge -y sudo && \
    rm -rf /etc/sudoers /etc/sudoers.d && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Disable network transfer tools (chmod 000, not rm, to avoid breaking dpkg database)
# Lock package managers and remove pip
RUN chmod 000 /usr/bin/curl /usr/bin/wget 2>/dev/null || true && \
    chmod 000 /usr/bin/ssh /usr/bin/scp /usr/bin/sftp 2>/dev/null || true && \
    chmod 000 /usr/bin/ftp 2>/dev/null || true && \
    chmod 000 /usr/bin/nc /usr/bin/netcat /usr/bin/ncat 2>/dev/null || true && \
    chmod 000 /usr/bin/rsync /usr/bin/aria2c 2>/dev/null || true && \
    rm -f /usr/bin/pip /usr/bin/pip3 /usr/local/bin/pip /usr/local/bin/pip3 && \
    rm -rf /usr/lib/python3/dist-packages/pip && \
    chmod 000 /usr/bin/apt /usr/bin/apt-get /usr/bin/dpkg 2>/dev/null || true && \
    chmod 000 /usr/bin/snap 2>/dev/null || true

# Disable all peripheral services at image level
ENV KASM_SVC_AUDIO=0 \
    KASM_SVC_AUDIO_INPUT=0 \
    KASM_SVC_UPLOADS=0 \
    KASM_SVC_GAMEPAD=0 \
    KASM_SVC_WEBCAM=0 \
    KASM_SVC_PRINTER=0 \
    DLP_PROCESS_FAIL_SECURE=1

USER kasm-user
WORKDIR /home/kasm-user

ENTRYPOINT [ "/dockerstartup/vnc_startup.sh" ]
