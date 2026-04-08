#!/bin/sh
set -eu

# hhhz - 好好活着
# One-line installer: curl -fsSL https://raw.githubusercontent.com/CherrySun/hhhz/main/install.sh | sh

REPO="CherrySun/hhhz"
INSTALL_DIR="$HOME/.local/bin"
BINARY="$INSTALL_DIR/hhhz"

echo ""
echo "  🌱 安装 hhhz (好好活着)..."
echo ""

# macOS only
if [ "$(uname -s)" != "Darwin" ]; then
    echo "  ❌ hhhz 仅支持 macOS"
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
    echo "  ❌ 不支持的架构: $ARCH"
    exit 1
fi

# Download binary
DOWNLOAD_URL="https://github.com/$REPO/releases/latest/download/$ASSET"
echo "  ⬇️  下载中..."
if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$DOWNLOAD_URL" -o "$BINARY"
elif command -v wget >/dev/null 2>&1; then
    wget -q "$DOWNLOAD_URL" -O "$BINARY"
else
    echo "  ❌ 需要 curl 或 wget"
    exit 1
fi

chmod +x "$BINARY"

# Remove macOS quarantine attribute (prevents Gatekeeper blocking unsigned binary)
xattr -d com.apple.quarantine "$BINARY" 2>/dev/null || true

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
        echo "  ⚠️  请将 ~/.local/bin 加入 PATH:"
        echo "     echo 'export PATH=\"\$HOME/.local/bin:\$PATH\"' >> $RC_FILE"
        echo ""
        ;;
esac

# Run install (registers LaunchAgent + starts daemon)
"$BINARY"
