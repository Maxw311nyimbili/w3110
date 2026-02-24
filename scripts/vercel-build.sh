#!/bin/bash

# Exit on error
set -e

echo "Starting Vercel Build Process..."

# 1. Install Flutter (using a specific version for stability)
# Vercel environments are Linux-based
FLUTTER_VERSION="3.35.0"
FLUTTER_CHANNEL="stable"

if [ ! -d "flutter" ]; then
  echo "Downloading Flutter SDK..."
  curl -O https://storage.googleapis.com/flutter_infra_release/releases/${FLUTTER_CHANNEL}/linux/flutter_linux_${FLUTTER_VERSION}-${FLUTTER_CHANNEL}.tar.xz
  tar xf flutter_linux_${FLUTTER_VERSION}-${FLUTTER_CHANNEL}.tar.xz
  rm flutter_linux_${FLUTTER_VERSION}-${FLUTTER_CHANNEL}.tar.xz
fi

# 2. Add Flutter to PATH and fix ownership
export PATH="$PATH:`pwd`/flutter/bin"

# Fix "dubious ownership" error in the build environment
git config --global --add safe.directory "*"

# 3. Configure and Build
echo "Configuring Flutter..."
# Avoid root warning if possible, though Vercel runs as root usually
export PUB_CACHE="`pwd`/.pub-cache"
export PATH="$PATH:$PUB_CACHE/bin"

flutter config --no-analytics
flutter config --enable-web
# flutter doctor --android-licenses # Not needed for web

echo "Fetching dependencies..."
flutter pub get

echo "Building Web App (Release mode)..."
# Use --no-color to clean up logs if needed
flutter build web --release --no-pub -t lib/main_development.dart

echo "Build complete! Output is in build/web"
