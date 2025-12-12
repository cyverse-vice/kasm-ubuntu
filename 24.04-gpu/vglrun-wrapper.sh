#!/bin/bash
# vglrun-wrapper.sh - Launch applications with GPU acceleration when available

APP="$@"

# Find vglrun location (check common paths)
if command -v vglrun &>/dev/null; then
    VGLRUN="vglrun"
elif [ -x "/opt/VirtualGL/bin/vglrun" ]; then
    VGLRUN="/opt/VirtualGL/bin/vglrun"
else
    VGLRUN=""
fi

# Check if VirtualGL is available and we have GPU devices
if [ -n "$VGLRUN" ] && [ -d "/dev/dri" ]; then
    echo "Starting with GPU Acceleration via VirtualGL (EGL backend)"
    exec env VGL_DISPLAY=egl "$VGLRUN" $APP
else
    echo "Starting without GPU acceleration (software rendering)"
    exec $APP
fi
