#!/bin/bash
set -e  # Exit on error

# Download latest stable nvim with error checking
if ! -f nvim-linux-x86_64.tar.gz; then
    echo "Downloading Neovim..."
    if ! curl -fLO https://github.com/neovim/neovim/releases/download/stable/nvim-linux-x86_64.tar.gz; then
        echo "Error: Download failed"
        exit 1
    fi
else
    echo "file already present in directory"
fi

# Verify it's actually a gzip file
if ! file nvim-linux-x86_64.tar.gz | grep -q "gzip compressed"; then
    echo "Error: Downloaded file is not a valid gzip archive"
    echo "File content:"
    head -20 nvim-linux-x86_64.tar.gz
    rm nvim-linux-x86_64.tar.gz
    exit 1
fi

# Extract to /opt
echo "Extracting Neovim..."
sudo rm -rf /opt/nvim-linux-x86_64
sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz
# Fix ownership to root
sudo chown -R root:root /opt/nvim-linux-x86_64

# Get version number
NVIM_VERSION=$(/opt/nvim-linux-x86_64/bin/nvim --version | head -1 | grep -oP 'v\K[0-9.]+')
echo "Installing Neovim ${NVIM_VERSION}..."

# Rename to versioned directory
sudo mv /opt/nvim-linux-x86_64 /opt/nvim-"${NVIM_VERSION}"

# Create symlink to versioned directory
sudo rm -f /opt/nvim
sudo ln -s /opt/nvim-"${NVIM_VERSION}" /opt/nvim

# Make available in PATH via /usr/local/bin
sudo ln -sf /opt/nvim/bin/nvim /usr/local/bin/nvim

# Cleanup
rm nvim-linux-x86_64.tar.gz

echo "Neovim ${NVIM_VERSION} installed successfully!"
nvim --version
