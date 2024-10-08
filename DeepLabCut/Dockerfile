FROM kasmweb/ubuntu-focal-desktop:1.14.0-rolling

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

RUN sudo apt-get update -y && \
    sudo apt-get upgrade -y && \
    sudo apt-get install -y gnome-session gnome-shell gnome-control-center gnome-terminal gnome-system-monitor gnome-tweak-tool gcc make linux-headers-$(uname -r) --no-install-recommends && \
    sudo apt-get clean

# Install NVIDIA dependencies
RUN sudo add-apt-repository ppa:graphics-drivers/ppa && \
    sudo apt update -y && \
    sudo apt install ubuntu-drivers-common -y && \
    sudo apt dist-upgrade  

RUN wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-keyring_1.1-1_all.deb
RUN sudo dpkg -i cuda-keyring_1.1-1_all.deb
RUN sudo apt install nvidia-driver-535 -y
# RUN sudo apt-get install tensorrt -y

# RUN sudo apt update # && sudo apt upgrade -y # updating doesn't help

# Initialize conda
RUN echo "conda activate base" >> ~/.bashrc && \
    /bin/bash -c "conda init"

RUN mamba install python=3.10.* jupyter nb_conda notebook ffmpeg pytables=3.8.0 -c conda-forge -y
RUN pip install 'git+https://github.com/DeepLabCut/DeepLabCut.git@pytorch_dlc#egg=deeplabcut[gui,modelzoo,wandb]'
# RUN mamba install tensorflow-gpu -c conda-forge -y
# RUN mamba install python=3.10.* pytorch torchvision torchaudio pytorch-cuda=12.1 -c pytorch-nightly -c nvidia -c conda-forge -y
# RUN mamba install -c pytorch -c nvidia -c conda-forge python==3.10.* pytorch torchvision torchaudio pytorch-cuda==12.1  pytorch-lightning cudatoolkit cuda -y 
# RUN mamba install -c pytorch -c nvidia -c conda-forge python==3.10.* pytorch torchvision torchaudio pytorch-cuda  pytorch-lightning cudatoolkit cuda  mkl==2024.2.* -y

# RUN mamba install -c conda-forge mlflow pytables==3.8.0 -y

# RUN python -m pip install wheel && \
#     python -m pip install --pre --upgrade tensorrt

# RUN pip install tensorflow[and-cuda]

COPY kasmvnc_defaults.yaml /usr/share/kasmvnc/kasmvnc_defaults.yaml
COPY vnc_startup.sh /dockerstartup/vnc_startup.sh
#COPY sudoers /etc/sudoers

# Clean conda and set right privs
RUN conda clean --all -y
RUN sudo chown -R ${LOCAL_USER} /home/kasm-user/miniconda3

RUN sudo chmod +x /dockerstartup/vnc_startup.sh

# USER kasm-user

ENTRYPOINT [ "/dockerstartup/vnc_startup.sh" ]
