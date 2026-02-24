#!/bin/bash

# Exit on error
set -e

echo "Starting Vercel Build Process..."

# 1. Install Flutter (using a specific version for stability)
# Vercel environments are Linux-based
FLUTTER_VERSION="3.24.0"
FLUTTER_CHANNEL="stable"

if [ ! -d "flutter" ]; then
  echo "Downloading Flutter SDK..."
  curl -O https://storage.googleapis.com/flutter_infra_release/releases/${FLUTTER_CHANNEL}/linux/flutter_linux_${FLUTTER_VERSION}-${FLUTTER_CHANNEL}.tar.xz
  tar xf flutter_linux_${FLUTTER_VERSION}-${FLUTTER_CHANNEL}.tar.xz
  rm flutter_linux_${FLUTTER_VERSION}-${FLUTTER_CHANNEL}.tar.xz
fi

# 2. Add Flutter to PATH
export PATH="$PATH:`pwd`/flutter/bin"

# 3. Configure and Build
echo "Configuring Flutter..."
flutter config --enable-web
flutter doctor

echo "Fetching dependencies..."
flutter pub get

echo "Building Web App (Release mode)..."
flutter build web --release

echo "Build complete! Output is in build/web"
