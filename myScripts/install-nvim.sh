sh
#!/bin/bash
set -euo pipefail

# Download latest stable nvim with error checking
if [[ ! -f nvim-linux-x86_64.tar.gz ]]; then
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
sudo mkdir -p /opt/nvim
echo "Extracting Neovim..."
sudo rm -rf /opt/nvim/nvim-linux-x86_64
sudo tar -C /opt/nvim -xzf nvim-linux-x86_64.tar.gz
# Fix ownership to root
sudo chown -R root:root /opt/nvim/nvim-linux-x86_64
# Get version number
NVIM_VERSION=$(/opt/nvim/nvim-linux-x86_64/bin/nvim --version | head -1 | grep -oP 'v\K[0-9.]+')
if [[ ! "$NVIM_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "Error: could not determine a valid Neovim version (got: '${NVIM_VERSION}')"
    exit 1
fi
echo "Installing Neovim ${NVIM_VERSION}..."
# Rename to versioned directory
sudo rm -rf /opt/nvim/nvim-"${NVIM_VERSION}"
sudo mv /opt/nvim/nvim-linux-x86_64 /opt/nvim/nvim-"${NVIM_VERSION}"
# Make available in PATH via /usr/local/bin
sudo ln -sf /opt/nvim/nvim-"${NVIM_VERSION}"/bin/nvim /usr/local/bin/nvim
# Cleanup
rm nvim-linux-x86_64.tar.gz
echo "Neovim ${NVIM_VERSION} installed successfully!"
nvim --version
