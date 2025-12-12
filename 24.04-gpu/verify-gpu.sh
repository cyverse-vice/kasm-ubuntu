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
echo "VGL_DISPLAY: ${VGL_DISPLAY:-not set}"
echo "KASM_EGL_CARD: ${KASM_EGL_CARD:-not set}"
echo "KASM_RENDERD: ${KASM_RENDERD:-not set}"

echo -e "\n--- EGL Info (Surfaceless) ---"
if command -v eglinfo &> /dev/null; then
    eglinfo 2>/dev/null | grep -A5 "Surfaceless platform" | head -10
else
    echo "eglinfo not available"
fi

echo -e "\n--- GLX Info (without VirtualGL) ---"
if command -v glxinfo &> /dev/null; then
    echo "Direct GLX (expected to fail on Xvnc):"
    glxinfo -B 2>&1 | head -5
else
    echo "glxinfo not available"
fi

echo -e "\n--- VirtualGL Test (EGL backend) ---"
if command -v vglrun &> /dev/null; then
    echo "Testing: VGL_DISPLAY=egl vglrun glxinfo"
    VGL_DISPLAY=egl vglrun glxinfo -B 2>/dev/null | grep -E "vendor|renderer|version|direct rendering"
else
    echo "VirtualGL (vglrun) not found in PATH"
fi

echo -e "\n--- Quick Benchmark Test ---"
if command -v glmark2 &> /dev/null && command -v vglrun &> /dev/null; then
    echo "Running: VGL_DISPLAY=egl vglrun glmark2 (first 3 tests)..."
    timeout 30 bash -c 'VGL_DISPLAY=egl vglrun glmark2 2>&1 | head -20'
fi

echo -e "\n=========================================="
echo "SUCCESS: GL_RENDERER should show 'NVIDIA' GPU"
echo "FAILURE: GL_RENDERER shows 'llvmpipe' or GLX errors"
echo "=========================================="
