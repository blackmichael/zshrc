#!/bin/bash

# Define a list of packages to install
packages=(
    "antidote"
    "wget"
    "tree"
    "fzf"
    "jq"
    "pyenv"
    "jump"
    "findutils"
    "go"
    "postgres"
    "protobuf"
    "grpcurl"
    "openjdk"
    "kotlin"
    "kafkacat"
    "nvm"
    "yarn"
    "bufbuild/buf/buf"
    "topicctl"
    "autojump"
    "colima"
    "docker"
    "docker-compose"
    "mysql-client"
    "awscli"
    "terraform"
    "helm"
    "redis-cli"
    "autojump"
    "watch"
    "tabby"
    "bazelisk"
)

# Check if Homebrew is installed
if ! command -v brew &>/dev/null; then
    echo "Homebrew is not installed. Installing it now..."
    
    # Install Homebrew (for macOS)
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # If you're also considering Linux, you can uncomment the following lines:
    #if [[ "$(uname)" == "Linux" ]]; then
    #    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    #fi
fi

# Install each package
for pkg in "${packages[@]}"; do
    if brew list "$pkg" &>/dev/null; then
        echo "$pkg is already installed."
    else
        echo "Installing $pkg..."
        brew install "$pkg"
    fi
done

# Shell history
curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh

echo "All packages installed successfully!"

