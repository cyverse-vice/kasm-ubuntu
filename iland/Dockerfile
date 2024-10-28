FROM harbor.cyverse.org/vice/kasm/ubuntu:qgis-22.04

# Install required packages and dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    libgl1-mesa-dev \
    python3 \
    python-is-python3 \
    cmake \
    git \
    perl \
    libfontconfig1-dev \
    libxkbcommon-x11-dev \
    libgtk-3-dev \
    libxcb1-dev \
    libxcb-keysyms1-dev \
    libxcb-randr0-dev \
    libxcb-shape0-dev \
    libxcb-shm0-dev \
    libxcb-xfixes0-dev \
    libxcb-sync-dev \
    libxcb-xinerama0-dev \
    libxcb-dri3-dev \
    ca-certificates \
    pkg-config

# Set the working directory
WORKDIR /opt

# Clone the Qt source code with a shallow clone
RUN git clone --depth 1 --branch 6.5 git://code.qt.io/qt/qt5.git qt6

# Initialize the repository
WORKDIR /opt/qt6
RUN perl init-repository

# Create a build directory for Qt
WORKDIR /opt
RUN mkdir qt6-build

# Configure Qt
WORKDIR /opt/qt6-build
RUN ../qt6/configure --prefix=/opt/qt6-build -opensource -confirm-license -sql-sqlite -no-opengl

# Build Qt
RUN cmake --build .

# Fix potential libQt6Core.so.6 error
WORKDIR /opt/qt6-build/qtbase/lib
RUN strip --remove-section=.note.ABI-tag libQt6Core.so.6 || true

# Rebuild Qt after stripping
WORKDIR /opt/qt6-build
RUN cmake --build .

# Install Qt
RUN cmake --install .

# Update environment variables for Qt
ENV PATH="/opt/qt6-build/bin:${PATH}"
ENV LD_LIBRARY_PATH="/opt/qt6-build/lib:${LD_LIBRARY_PATH}"

# Clone the iLand source code with a shallow clone
WORKDIR /opt
RUN git clone --depth 1 https://github.com/edfm-tum/iland-model

# Create build directories for iLand
WORKDIR /opt/iland-model
RUN mkdir -p build/plugins build/ilandc build/iland

# Build iLand plugins
WORKDIR /opt/iland-model/build/plugins
RUN qmake ../../src/plugins/plugins.pro
RUN make

# Build iLand command-line version
WORKDIR /opt/iland-model/build/ilandc
RUN qmake ../../src/ilandc/ilandc.pro
RUN make

# Build iLand GUI version
WORKDIR /opt/iland-model/build/iland
RUN qmake ../../src/iland/iland.pro
RUN make

# Copy the executables to a directory in PATH
RUN cp /opt/iland-model/build/ilandc/ilandc /usr/local/bin/
RUN cp /opt/iland-model/build/iland/iland /usr/local/bin/

# Set the default command
CMD ["/bin/bash"]
