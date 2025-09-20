#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_DIR="$SCRIPT_DIR/dynamic-pricing"
IMAGE_NAME="dynamic-pricing-proxy"

echo "Building Docker image: $IMAGE_NAME"
docker build -t "$IMAGE_NAME" "$APP_DIR"
echo "Build complete: $IMAGE_NAME"
