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
RUN sudo add-apt-repository ppa:graphics-drivers/ppa -y && \
    sudo apt update -y && \
    sudo apt install ubuntu-drivers-common -y && \
    sudo apt dist-upgrade -y 

# Install cuda toolkit
RUN apt-get update && \
    apt-get install -y wget gnupg && \
    wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-keyring_1.0-1_all.deb && \
    dpkg -i cuda-keyring_1.0-1_all.deb && \
    apt-get update
RUN sudo apt-get install -y cuda-toolkit-12-1
  
# Add CUDA to PATH
ENV PATH=/usr/local/cuda/bin:$PATH
ENV LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH

# Install NVIDIA driver
RUN sudo apt install nvidia-driver-555 -y

# Initialize conda
RUN echo "conda activate base" >> ~/.bashrc && \
    /bin/bash -c "conda init"

# Install python
RUN mamba install python=3.10.* -c conda-forge -y

# Set correct pytorch/nvidia environment vars
ENV PYTORCH_NVML_BASED_CUDA_CHECK=1
ENV NVIDIA_VISIBLE_DEVICES=all

# install pyTorch
RUN conda install pytorch-cuda=12.1 -c pytorch -c nvidia

COPY kasmvnc_defaults.yaml /usr/share/kasmvnc/kasmvnc_defaults.yaml
COPY vnc_startup.sh /dockerstartup/vnc_startup.sh

# Clean conda and set right privs
RUN conda clean --all -y
RUN sudo chown -R ${LOCAL_USER} /home/kasm-user/miniconda3

# Set right permissions
RUN sudo chmod +x /dockerstartup/vnc_startup.sh


#########

COPY DEEPLABCUT.yaml /home/kasm-user/data-store/DEEPLABCUT.yaml

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive
    
#RUN conda install -c conda-forge pytables==3.8.0
#RUN pip install git+https://github.com/DeepLabCut/DeepLabCut.git@pytorch_dlc#egg=deeplabcut[gui,modelzoo,wandb]

#RUN pip install --upgrade numexpr
#RUN pip install torch==2.0.1 torchvision==0.15.2 torchaudio

#RUN conda install cudnn -c conda-forge
RUN conda env create -f DEEPLABCUT.yaml
RUN conda env update -f DEEPLABCUT.yaml

RUN /bin/bash -c "source activate DEEPLABCUT && \
    pip install --force-reinstall --no-deps shiboken6==6.8.0.2 && \
    conda install pyside6 -c conda-forge -y"

# Ensure the environment is activated in the shell session
SHELL ["conda", "run", "-n", "DEEPLABCUT", "/bin/bash", "-c"]


ENV CUDA_VISIBLE_DEVICES=0

#USER kasm-user

#RUN echo "conda activate DEEPLABCUT" >> ~/.bashrc

RUN sudo apt update && sudo apt update


#USER kasm-user

ENTRYPOINT [ "/dockerstartup/vnc_startup.sh" ]
#ENTRYPOINT [  "/bin/bash" ]
