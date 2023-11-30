FROM harbor.cyverse.org/vice/kasm/ubuntu:22.04

USER root

# Install ImageJ
RUN apt-get update && \
    apt-get install -y \
    default-jre \
    default-jdk \
    && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /opt/ImageJ && \
    wget https://downloads.imagej.net/fiji/latest/fiji-linux64.zip && \
    # unzip .zip file to /opt/ImageJ
    unzip -o fiji-linux64.zip -d /opt/ImageJ  && \
    rm -rf fiji-linux64.zip && \
    chown -R kasm-user:kasm-user /opt/ImageJ && \
    ln -s /opt/ImageJ/Fiji.app/ImageJ-linux64 /usr/local/bin/imagej

USER kasm-user

RUN mkdir -p ~/.local/share/applications && \
    echo "[Desktop Entry]" >> ~/.local/share/applications/imagej.desktop && \
    echo "Name=ImageJ" >> ~/.local/share/applications/imagej.desktop && \
    echo "Exec=/bin/bash -c 'imagej'" >> ~/.local/share/applications/imagej.desktop && \
    echo "Icon=" >> ~/.local/share/applications/imagej.desktop && \
    echo "Type=Application" >> ~/.local/share/applications/imagej.desktop && \
    echo "Categories=Application;Development;" >> ~/.local/share/applications/imagej.desktop && \
    echo "Terminal=false" >> ~/.local/share/applications/imagej.desktop

USER root

RUN mkdir /home/kasm-user/Desktop && \
    echo "[Desktop Entry]\nType=Application\nName=ImageJ\nExec=/usr/local/bin/imagej\nIcon=/opt/ImageJ/Fiji.app/images/icon.png\nTerminal=false\nCategories=Science;ImageProcessing;" > /home/kasm-user/Desktop/ImageJ2.desktop && \
    chmod +x /home/kasm-user/Desktop/ImageJ2.desktop && \
    chown kasm-user:kasm-user /home/kasm-user/Desktop/ImageJ2.desktop