#!/bin/bash
set -euo pipefail

# hhhz - 好好活着
# One-line installer

REPO="CherrySun/hhhz"
INSTALL_DIR="$HOME/.local/bin"
BINARY="$INSTALL_DIR/hhhz"

echo ""
echo "  🌱 安装 hhhz (好好活着)..."
echo ""

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
if command -v curl &> /dev/null; then
    curl -fsSL "$DOWNLOAD_URL" -o "$BINARY"
elif command -v wget &> /dev/null; then
    wget -q "$DOWNLOAD_URL" -O "$BINARY"
else
    echo "  ❌ 需要 curl 或 wget"
    exit 1
fi

chmod +x "$BINARY"

# Ensure ~/.local/bin is in PATH
if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
    echo ""
    echo "  ⚠️  请将 ~/.local/bin 加入 PATH:"
    echo "     echo 'export PATH=\"\$HOME/.local/bin:\$PATH\"' >> ~/.zshrc"
    echo ""
fi

# Run install (registers LaunchAgent + starts daemon)
"$BINARY"
