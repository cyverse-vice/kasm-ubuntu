FROM kasmweb/ubuntu-jammy-desktop:1.16.0

# create ~/data-store for CSI driver fuse mount
WORKDIR /home/kasm-user/data-store

# Install GoCommands
RUN mkdir /home/kasm-user/.irods
RUN echo '{"irods_host": "data.cyverse.org", "irods_port": 1247, "irods_user_name": "$IPLANT_USER", "irods_zone_name": "iplant"}' | envsubst > /home/kasm-user/.irods/irods_environment.json

USER root

# Install a few dependencies for goCommands, text editing, and monitoring instances
RUN apt update && \
    apt install -y lsb-release apt-transport-https curl libfreetype6-dev pkg-config libx11-dev gcc less software-properties-common apt-utils glances htop nano 

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
    echo "$LOCAL_USER ALL=NOPASSWD: $PRIV_CMDS" >> /etc/sudoersq

# USER kasm-user

# Add conda
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

# Update, upgrade, and install necessary packages
RUN apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install -y gnome-session gnome-shell gnome-control-center \
                       gnome-terminal gnome-system-monitor gnome-tweak-tool \
                       gcc make --no-install-recommends && \
    apt-get install -y linux-headers-$(uname -r) || apt-get install -y linux-headers-generic && \
    apt-get clean

# Install NVIDIA dependencies
RUN sudo add-apt-repository ppa:graphics-drivers/ppa && \
    sudo apt update -y && \
    sudo apt install ubuntu-drivers-common -y && \
    sudo apt dist-upgrade  

RUN apt-get update && \
    apt-get install -y wget gnupg && \
    wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-keyring_1.0-1_all.deb && \
    dpkg -i cuda-keyring_1.0-1_all.deb && \
    apt-get update
RUN sudo apt-get install -y cuda-toolkit-12-1
  
# Add CUDA to PATH
ENV PATH=/usr/local/cuda/bin:$PATH
ENV LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH

RUN sudo apt install nvidia-driver-555 -y

# Initialize conda
RUN echo "conda activate base" >> ~/.bashrc && \
    /bin/bash -c "conda init"

# Install python
RUN mamba install python=3.10.* -c conda-forge -y

ENV PYTORCH_NVML_BASED_CUDA_CHECK=1
ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=compute,utility

# install pyTorch
#RUN conda install torchvision torchaudio pytorch-cuda=12.1 -c pytorch -c nvidia -y
RUN conda install pytorch-gpu torchvision torchaudio pytorch-cuda=12.1 -c pytorch -c nvidia

COPY kasmvnc_defaults.yaml /usr/share/kasmvnc/kasmvnc_defaults.yaml
COPY vnc_startup.sh /dockerstartup/vnc_startup.sh
#COPY sudoers /etc/sudoers

# Clean conda and set right privs
RUN conda clean --all -y
RUN sudo chown -R ${LOCAL_USER} /home/kasm-user/miniconda3

RUN sudo chmod +x /dockerstartup/vnc_startup.sh

# USER kasm-user

ENTRYPOINT [ "/bin/bash" ]
