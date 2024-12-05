FROM kasmweb/desktop-deluxe:1.15.0-rolling

# create ~/data-store for CSI driver fuse mount
WORKDIR /home/kasm-user/data-store
    
# Install GoCommands
RUN mkdir /home/kasm-user/.irods
RUN echo '{"irods_host": "data.cyverse.org", "irods_port": 1247, "irods_user_name": "$IPLANT_USER", "irods_zone_name": "iplant"}' | envsubst > /home/kasm-user/.irods/irods_environment.json
    
USER root
    
# Install a few dependencies for goCommands, text editing, and monitoring instances
RUN apt update && \
    apt install -y lsb-release apt-transport-https curl libfreetype6-dev pkg-config libx11-dev gcc less software-properties-common apt-utils glances htop nano 
    
# install conda
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p /home/kasm-user/miniconda3 && \
    rm ~/miniconda.sh
    
RUN sudo ln -s /home/kasm-user/miniconda3/etc/profile.d/conda.sh /etc/profile.d/conda.sh
    
RUN echo ". /home/kasm-user/miniconda3/etc/profile.d/conda.sh" >> /home/${LOCAL_USER}/.bashrc && \
    echo ". /home/kasm-user/miniconda3/etc/profile.d/conda.sh" >> /home/${LOCAL_USER}/.zshrc && \
    sudo chown -R ${LOCAL_USER}:${LOCAL_USER} /home/kasm-user/miniconda3

# Add conda to PATH
ENV PATH=/home/kasm-user/miniconda3/bin:$PATH

# Install dependencies
RUN conda install -c conda-forge mamba -y
# Install CellProfiler Dependencies
RUN apt-get update && \
    apt-get install -y \
    make \
    gcc \
    build-essential \
    libgtk-3-dev \
    openjdk-11-jdk-headless \
    default-libmysqlclient-dev \
    libnotify-dev \
    libsdl2-dev \
    python3-pip \
    python3-tk \
    freeglut3 \
    freeglut3-dev \
    libgl1-mesa-dev \
    libglu1-mesa-dev \
    libgstreamer-plugins-base1.0-dev \
    libgtk-3-dev \
    libjpeg-dev \
    libnotify-dev \
    libsdl2-dev \
    libsm-dev \
    libtiff-dev \
    libwebkit2gtk-4.0-dev \
    libxtst-dev \
    nano \
    && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install Go
RUN wget -q -c https://dl.google.com/go/go1.20.5.linux-amd64.tar.gz -O - | tar -xz -C /usr/local
ENV PATH=$PATH:/usr/local/go/bin

# Install GoCommands
RUN cd /usr/local/bin/ && \
    GOCMD_VER=$(curl -L -s https://raw.githubusercontent.com/cyverse/gocommands/main/VERSION.txt); \
    curl -L -s https://github.com/cyverse/gocommands/releases/download/${GOCMD_VER}/gocmd-${GOCMD_VER}-linux-amd64.tar.gz | tar zxvf -

# Add sudo to jovyan user
RUN apt update && \
    apt install -y sudo && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

ARG LOCAL_USER=kasm-user

# all sudo powers
ARG PRIV_CMDS='ALL'
# uncomment to limited sudo powers
# ARG PRIV_CMDS='/bin/ch*,/bin/cat,/bin/gunzip,/bin/tar,/bin/mkdir,/bin/ps,/bin/mv,/bin/cp,/usr/bin/apt*,/usr/bin/pip*,/bin/yum,/bin/snap,/bin/curl,/bin/tee,/opt'

RUN usermod -aG sudo kasm-user && \
    echo "$LOCAL_USER ALL=NOPASSWD: $PRIV_CMDS" >> /etc/sudoers

RUN chmod a+x /dockerstartup/vnc_startup.sh

RUN apt-get update && \
    apt-get install -y gnome-session gnome-shell gnome-control-center gnome-terminal gnome-system-monitor gnome-tweak-tool --no-install-recommends && \
    apt-get clean

COPY kasmvnc_defaults.yaml /usr/share/kasmvnc/kasmvnc_defaults.yaml
COPY vnc_startup.sh /dockerstartup/vnc_startup.sh
#COPY sudoers /etc/sudoers

#USER kasm-user

# Adding Java home to bashrc &
# Install CellProfiler
COPY environment.yml /home/kasm-user/environment.yml
RUN cd && \
    conda install -c conda-forge mamba -y && \
    mamba env create -f environment.yml -y && \
    echo "source activate cellprofiler" >> ~/.bashrc && \
    echo "export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64" >> ~/.bashrc && \
    /bin/bash -c "source activate cellprofiler"

# add `cellprofiler` `cellpose` and `imagej` to Gnome Applications Menu
RUN mkdir -p ~/.local/share/applications && \
    echo "[Desktop Entry]" >> ~/.local/share/applications/cellprofiler.desktop && \
    echo "Name=CellProfiler" >> ~/.local/share/applications/cellprofiler.desktop && \
    echo "Exec=/bin/bash -c 'source activate cellprofiler && cellprofiler'" >> ~/.local/share/applications/cellprofiler.desktop && \
    echo "Icon=" >> ~/.local/share/applications/cellprofiler.desktop && \
    echo "Type=Application" >> ~/.local/share/applications/cellprofiler.desktop && \
    echo "Categories=Application;Development;" >> ~/.local/share/applications/cellprofiler.desktop && \
    echo "Terminal=false" >> ~/.local/share/applications/cellprofiler.desktop && \
    echo "[Desktop Entry]" >> ~/.local/share/applications/imagej.desktop && \
    echo "Name=ImageJ" >> ~/.local/share/applications/imagej.desktop && \
    echo "Exec=/bin/bash -c 'source activate cellprofiler && imagej'" >> ~/.local/share/applications/imagej.desktop && \
    echo "Icon=" >> ~/.local/share/applications/imagej.desktop && \
    echo "Type=Application" >> ~/.local/share/applications/imagej.desktop && \
    echo "Categories=Application;Development;" >> ~/.local/share/applications/imagej.desktop && \
    echo "Terminal=false" >> ~/.local/share/applications/imagej.desktop && \
    echo "[Desktop Entry]" >> ~/.local/share/applications/cellpose.desktop && \
    echo "Name=CellPose" >> ~/.local/share/applications/cellpose.desktop && \
    echo "Exec=/bin/bash -c 'source activate cellprofiler && cellpose'" >> ~/.local/share/applications/cellpose.desktop && \
    echo "Icon=" >> ~/.local/share/applications/cellpose.desktop && \
    echo "Type=Application" >> ~/.local/share/applications/cellpose.desktop && \
    echo "Categories=Application;Development;" >> ~/.local/share/applications/cellpose.desktop && \
    echo "Terminal=false" >> ~/.local/share/applications/cellpose.desktop

# Install CellProfiler Plugins
RUN cd && \
    git clone https://github.com/CellProfiler/CellProfiler-plugins.git

COPY CellProfilerLocal.cfg /home/kasm-user

RUN chmod a+x /dockerstartup/vnc_startup.sh

# adding right permissions
RUN chmod -R a+wx /home/kasm-user/

USER kasm-user

ENTRYPOINT [ "/dockerstartup/vnc_startup.sh" ]

