#!/bin/bash
set -e

echo "======================================"
echo " Phantom Tunes — Flutter Dev Setup"
echo " CachyOS (Arch-based)"
echo "======================================"

# ─── Step 1: Install system dependencies ───
echo ""
echo "[1/6] Installing system dependencies (JDK 17, build tools)..."
sudo pacman -S --needed --noconfirm \
  jdk17-openjdk \
  base-devel \
  cmake \
  ninja \
  clang \
  gtk3 \
  xz \
  unzip \
  which

# Set JDK 17 as default
echo ""
echo "[1b/6] Setting JDK 17 as default Java..."
sudo archlinux-java set java-17-openjdk

# Verify
echo "Java version:"
java -version 2>&1

# ─── Step 2: Install Flutter SDK ───
echo ""
echo "[2/6] Installing Flutter SDK..."
FLUTTER_DIR="$HOME/flutter-sdk"

if [ -d "$FLUTTER_DIR" ]; then
  echo "Flutter SDK already exists at $FLUTTER_DIR, updating..."
  cd "$FLUTTER_DIR"
  git pull
  cd -
else
  echo "Cloning Flutter stable..."
  git clone https://github.com/flutter/flutter.git -b stable "$FLUTTER_DIR"
fi

# ─── Step 3: Add Flutter to PATH ───
echo ""
echo "[3/6] Configuring PATH..."

# For Fish shell (user's default shell)
FISH_CONFIG="$HOME/.config/fish/config.fish"
mkdir -p "$(dirname "$FISH_CONFIG")"

if ! grep -q "flutter-sdk" "$FISH_CONFIG" 2>/dev/null; then
  echo "" >> "$FISH_CONFIG"
  echo "# Flutter SDK" >> "$FISH_CONFIG"
  echo "set -gx PATH \$HOME/flutter-sdk/bin \$PATH" >> "$FISH_CONFIG"
  echo "set -gx ANDROID_HOME \$HOME/Android/Sdk" >> "$FISH_CONFIG"
  echo "set -gx PATH \$ANDROID_HOME/cmdline-tools/latest/bin \$ANDROID_HOME/platform-tools \$PATH" >> "$FISH_CONFIG"
  echo "Added Flutter to Fish config"
else
  echo "Flutter already in Fish config"
fi

# Also add to bashrc for non-fish shells (like this script)
if ! grep -q "flutter-sdk" "$HOME/.bashrc" 2>/dev/null; then
  echo "" >> "$HOME/.bashrc"
  echo "# Flutter SDK" >> "$HOME/.bashrc"
  echo 'export PATH="$HOME/flutter-sdk/bin:$PATH"' >> "$HOME/.bashrc"
  echo 'export ANDROID_HOME="$HOME/Android/Sdk"' >> "$HOME/.bashrc"
  echo 'export PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$PATH"' >> "$HOME/.bashrc"
  echo "Added Flutter to .bashrc"
else
  echo "Flutter already in .bashrc"
fi

# Source for this session
export PATH="$FLUTTER_DIR/bin:$PATH"

# ─── Step 4: Precache Flutter + Install Android SDK ───
echo ""
echo "[4/6] Running flutter precache..."
flutter precache

echo ""
echo "[4b/6] Setting up Android SDK..."
mkdir -p "$HOME/Android/Sdk"

# Configure Flutter to use our Android SDK location
flutter config --android-sdk "$HOME/Android/Sdk"

# Download Android SDK components via Flutter
# First, let flutter doctor trigger the SDK download
flutter doctor --android-licenses <<< "y
y
y
y
y
y
y
y
" || true

# ─── Step 5: Install additional Android SDK components if needed ───
echo ""
echo "[5/6] Installing Android SDK components..."
export ANDROID_HOME="$HOME/Android/Sdk"
export PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$PATH"

# If sdkmanager exists, install required components
if command -v sdkmanager &>/dev/null; then
  sdkmanager --install \
    "platform-tools" \
    "platforms;android-35" \
    "build-tools;35.0.0" \
    "cmdline-tools;latest" \
    "ndk;27.0.12077973" || true
fi

# ─── Step 6: Run flutter doctor ───
echo ""
echo "[6/6] Running flutter doctor..."
flutter doctor -v

echo ""
echo "======================================"
echo " Setup complete!"
echo " Close and reopen your terminal,"
echo " then run: flutter doctor"
echo "======================================"
