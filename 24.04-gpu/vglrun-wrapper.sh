#!/bin/bash
# vglrun-wrapper.sh - Launch applications with GPU acceleration when available

APP="$@"

# Check if VirtualGL is installed and GPU devices are available
if [ -f /opt/VirtualGL/bin/vglrun ] && \
   [ -n "${KASM_EGL_CARD}" ] && \
   [ -n "${KASM_RENDERD}" ] && \
   [ -O "${KASM_RENDERD}" ] && \
   [ -O "${KASM_EGL_CARD}" ]; then
    
    echo "Starting with GPU Acceleration on EGL device ${KASM_EGL_CARD}"
    exec /opt/VirtualGL/bin/vglrun -d "${KASM_EGL_CARD}" $APP
else
    # Fallback: Check if /dev/dri devices exist without KASM variables
    if [ -f /opt/VirtualGL/bin/vglrun ] && [ -e "/dev/dri/card0" ]; then
        echo "Starting with GPU Acceleration on /dev/dri/card0"
        exec /opt/VirtualGL/bin/vglrun -d egl $APP
    else
        echo "Starting without GPU acceleration (software rendering)"
        exec $APP
    fi
fi