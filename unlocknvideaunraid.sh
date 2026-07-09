#!/bin/bash
set -euo pipefail
WORKDIR="/tmp/nvidia-patch"
DRIVER_VERSION="$(nvidia-smi --query-gpu=driver_version --format=csv,noheader | head -n1)"

echo "Detected NVIDIA driver version: ${DRIVER_VERSION}"

mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# Download the patch script, aborting if it fails
if ! wget -q -O patch.sh https://raw.githubusercontent.com/keylase/nvidia-patch/master/patch.sh; then
    echo "ERROR: failed to download patch.sh — aborting, driver left untouched."
    exit 1
fi
chmod +x ./patch.sh

if ./patch.sh -c "${DRIVER_VERSION}"; then
    echo "Driver ${DRIVER_VERSION} is supported — applying NVENC patch."
    ./patch.sh
    echo "NVENC patch applied."
else
    echo "ERROR: driver ${DRIVER_VERSION} is NOT in the patch database — not patching."
    exit 1
fi
