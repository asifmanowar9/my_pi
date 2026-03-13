#!/usr/bin/env bash
set -euo pipefail

echo "==> Installing Flutter SDK"
if [ ! -d "$HOME/flutter" ]; then
  git clone https://github.com/flutter/flutter.git --depth 1 -b stable "$HOME/flutter"
fi

export PATH="$PATH:$HOME/flutter/bin"
flutter --version

echo "==> Enabling Flutter web"
flutter config --enable-web

echo "==> Getting dependencies"
flutter pub get

echo "==> Building web app"
flutter build web --release --no-wasm-dry-run

echo "==> Build complete: build/web"
