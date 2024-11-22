FROM kasmweb/ubuntu-focal-desktop:1.14.0-rolling

USER root

SHELL ["/bin/bash", "-c"]

# Install Python and linux depends
RUN apt-get update \
    && sudo apt-get upgrade -y \
    && apt-get install -y g++ virtualenv build-essential 

# define username as orange and limit its ownership
ARG LOCAL_USER=kasm-user
ENV LOCAL_USER=kasm-user

ARG PRIV_CMDS='/bin/ch*,/bin/cat,/bin/gunzip,/bin/tar,/bin/mkdir,/bin/ps,/bin/mv,/bin/cp,/usr/bin/apt*,/usr/bin/pip*,/bin/yum'

RUN usermod -aG sudo ${LOCAL_USER} && \
    echo "$LOCAL_USER ALL=NOPASSWD: $PRIV_CMDS" >> /etc/sudoers

RUN chown -R kasm-user:kasm-user /home/kasm-user

# Add conda
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p /home/kasm-user/miniconda3 && \
    rm ~/miniconda.sh

RUN sudo ln -s /home/kasm-user/miniconda3/etc/profile.d/conda.sh /etc/profile.d/conda.sh

#RUN echo ". /home/kasm-user/miniconda3/etc/profile.d/conda.sh" >> /home/${LOCAL_USER}/.bashrc && \
RUN echo ". /home/kasm-user/miniconda3/etc/profile.d/conda.sh" >> /home/${LOCAL_USER}/.zshrc && \    
    sudo chown -R ${LOCAL_USER}:${LOCAL_USER} /home/kasm-user/miniconda3

# Add conda to PATH
ENV PATH=/home/kasm-user/miniconda3/bin:$PATH

# Create user space for kasm
RUN mkdir -p /run/kasm-user/1001 && \
    chown -R ${LOCAL_USER}:${LOCAL_USER} /run/kasm-user && \
    mkdir -p /run/${LOCAL_USER}/1001 && \
    chown -R ${LOCAL_USER}:${LOCAL_USER} /run/${LOCAL_USER} # && \
   # echo ". /home/kasm-user/miniconda3/etc/profile.d/conda.sh" >> /home/${LOCAL_USER}/.bashrc && \
    #echo ". /home/kasm-user/miniconda3/etc/profile.d/conda.sh" >> /home/${LOCAL_USER}/.zshrc
#    chown -R ${LOCAL_USER}:1000 /opt/conda

# Create Orange user
ENV USER kasm-user
ENV PASSWORD kasm-user
ENV HOME /home/kasm-user
RUN echo kasm-user:1000 | chpasswd
RUN gpasswd -a kasm-user sudo

ADD ./icons/orange.png /usr/share/backgrounds/images/orange.png
ADD ./icons/orange.png .conda/share/orange3/orange.png
ADD ./orange/orange-canvas.desktop /home/${LOCAL_USER}Desktop/orange-canvas.desktop

#USER kasm-user

# create conda environment for Orange
COPY environment.yml /home/kasm-user/environment.yml
RUN conda install -c conda-forge -y mamba && \
    mamba env create -f environment.yml && \
    /bin/bash -c "conda init" && \
    /bin/bash -c "source activate orange"

# Activate Orange conda environments in bash and zsh
#RUN echo ". /home/kasm-user/miniconda3/etc/profile.d/conda.sh" >> ~/.bashrc && \
 #   echo "conda activate orange" >> ~/.bashrc
#RUN sudo chown -R kasm-user:1000 /home/kasm-user && \    
RUN    echo ". /home/kasm-user/miniconda3/etc/profile.d/conda.sh" >> ~/.zshrc && \
    echo "conda activate orange" >> ~/.zshrc

# set shell as zsh
ENV SHELL=zsh
ENV TERM=linux

ENV DISPLAY=:100
EXPOSE 6901

# changes tmux layout while running
COPY entry.sh /bin
RUN echo 'set-option -g status off' >> ~/.tmux.conf

COPY kasmvnc_defaults.yaml /usr/share/kasmvnc/kasmvnc_defaults.yaml
COPY vnc_startup.sh /dockerstartup/vnc_startup.sh

# add iRODS iCommands to user profile as JSON
RUN mkdir -p /home/kasm-user/.irods 

RUN sudo chmod a+x /dockerstartup/vnc_startup.sh

RUN apt-get update && apt-get install -y zsh

# Initialize Conda for zsh and activate the environment
#RUN zsh -c "source /home/kasm-user/miniconda3/etc/profile.d/conda.sh && \
 #   . ~/.zshrc && \
  #  conda activate orange"

RUN mkdir -p /home/kasm-user/.cache/Orange && \
    chown -R kasm-user:kasm-user /home/kasm-user/.cache

RUN chmod -R 755 /home/kasm-user/.cache

USER kasm-user

#RUN "bash" && \
#  "conda init" && \
#  "conda activate orange"

SHELL ["/bin/bash"]
CMD ["/bin/bash"]

ENTRYPOINT ["/dockerstartup/vnc_startup.sh", "/bin/zsh", "-c", "source /home/kasm-user/miniconda3/etc/profile.d/conda.sh && conda activate orange" ]

