#!/bin/sh
set -eu

# hhhz - a cute rest reminder for macOS
# One-line installer: curl -fsSL https://raw.githubusercontent.com/CherrySun/hhhz/main/install.sh | sh

REPO="CherrySun/hhhz"
INSTALL_DIR="$HOME/.local/bin"
BINARY="$INSTALL_DIR/hhhz"
PLIST="$HOME/Library/LaunchAgents/com.hhhz.daemon.plist"

echo ""
echo "  🌱 Installing hhhz..."
echo ""

# macOS only
if [ "$(uname -s)" != "Darwin" ]; then
    echo "  ❌ hhhz is macOS only"
    exit 1
fi

# Create install directory
mkdir -p "$INSTALL_DIR"

# Detect architecture
ARCH=$(uname -m)
if [ "$ARCH" = "arm64" ]; then
    ASSET="hhhz-arm64"
elif [ "$ARCH" = "x86_64" ]; then
    ASSET="hhhz-x86_64"
else
    echo "  ❌ Unsupported architecture: $ARCH"
    exit 1
fi

# Download binary
DOWNLOAD_URL="https://github.com/$REPO/releases/latest/download/$ASSET"
echo "  ⬇️  Downloading..."

# Decide download target: if already installed, download to temp file for upgrade
if [ -f "$PLIST" ] && [ -f "$BINARY" ]; then
    DOWNLOAD_TARGET=$(mktemp /tmp/hhhz.XXXXXX)
    IS_UPGRADE=1
else
    DOWNLOAD_TARGET="$BINARY"
    IS_UPGRADE=0
fi

if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$DOWNLOAD_URL" -o "$DOWNLOAD_TARGET"
elif command -v wget >/dev/null 2>&1; then
    wget -q "$DOWNLOAD_URL" -O "$DOWNLOAD_TARGET"
else
    echo "  ❌ curl or wget required"
    exit 1
fi

chmod +x "$DOWNLOAD_TARGET"

# Remove macOS quarantine attribute (prevents Gatekeeper blocking unsigned binary)
xattr -d com.apple.quarantine "$DOWNLOAD_TARGET" 2>/dev/null || true

if [ "$IS_UPGRADE" = "1" ]; then
    # Upgrade: run temp binary with upgrade command, then clean up
    "$DOWNLOAD_TARGET" upgrade
    rm -f "$DOWNLOAD_TARGET"
else
    # Fresh install
    # Ensure ~/.local/bin is in PATH
    case ":$PATH:" in
        *":$INSTALL_DIR:"*) ;;
        *)
            echo ""
            # Detect user's shell and suggest the right rc file
            SHELL_NAME=$(basename "$SHELL")
            if [ "$SHELL_NAME" = "zsh" ]; then
                RC_FILE="~/.zshrc"
            elif [ "$SHELL_NAME" = "bash" ]; then
                RC_FILE="~/.bash_profile"
            else
                RC_FILE="~/.profile"
            fi
            echo "  ⚠️  Please add ~/.local/bin to your PATH:"
            echo "     echo 'export PATH=\"\$HOME/.local/bin:\$PATH\"' >> $RC_FILE"
            echo ""
            ;;
    esac

    # Run install (registers LaunchAgent + starts daemon)
    "$BINARY"
fi
