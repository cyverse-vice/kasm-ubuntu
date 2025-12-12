#!/bin/bash
# verify-gpu.sh - Comprehensive GPU verification script

echo "=========================================="
echo "GPU Verification Report"
echo "=========================================="

echo -e "\n--- NVIDIA Driver Status ---"
if command -v nvidia-smi &> /dev/null; then
    nvidia-smi --query-gpu=name,driver_version,memory.total --format=csv
else
    echo "nvidia-smi not found"
fi

echo -e "\n--- DRI Devices ---"
ls -la /dev/dri/ 2>/dev/null || echo "No /dev/dri devices found"

echo -e "\n--- Environment Variables ---"
echo "NVIDIA_VISIBLE_DEVICES: ${NVIDIA_VISIBLE_DEVICES:-not set}"
echo "NVIDIA_DRIVER_CAPABILITIES: ${NVIDIA_DRIVER_CAPABILITIES:-not set}"
echo "KASM_EGL_CARD: ${KASM_EGL_CARD:-not set}"
echo "KASM_RENDERD: ${KASM_RENDERD:-not set}"

echo -e "\n--- EGL Info ---"
if command -v eglinfo &> /dev/null; then
    eglinfo | head -20
else
    echo "eglinfo not available"
fi

echo -e "\n--- GLX Info (current renderer) ---"
if command -v glxinfo &> /dev/null; then
    glxinfo -B 2>/dev/null | grep -E "vendor|renderer|version|direct rendering"
else
    echo "glxinfo not available"
fi

echo -e "\n--- VirtualGL Test ---"
if [ -f /opt/VirtualGL/bin/vglrun ]; then
    echo "VirtualGL installed at /opt/VirtualGL"
    if [ -e "/dev/dri/card0" ]; then
        echo "Testing vglrun with EGL backend..."
        /opt/VirtualGL/bin/vglrun -d egl glxinfo -B 2>/dev/null | grep -E "vendor|renderer"
    fi
else
    echo "VirtualGL not installed"
fi

echo -e "\n=========================================="
echo "Expected: GL_RENDERER should show NVIDIA GPU, not 'llvmpipe'"
echo "=========================================="