#!/bin/bash
# Quick fix for Docker installation conflicts

echo "🐳 Docker Installation Conflict Resolver"
echo ""

# Check current Docker installation
if command -v docker >/dev/null 2>&1; then
    DOCKER_VERSION=$(docker --version 2>/dev/null | cut -d' ' -f3 | tr -d ',')
    echo "Current Docker: $DOCKER_VERSION at $(which docker)"
else
    echo "❌ Docker not found"
    exit 1
fi

# Check if managed by pacman
if pacman -Qi docker >/dev/null 2>&1; then
    echo "✅ Docker is properly managed by pacman"
    exit 0
fi

echo "⚠️  Docker is installed but not managed by pacman"
echo ""
echo "Options:"
echo "1. Keep current Docker (skip pacman installation)"
echo "2. Backup and reinstall via pacman"
echo "3. Force overwrite with pacman"
echo ""

read -p "Choose option (1/2/3): " -n 1 -r
echo ""

case $REPLY in
    1)
        echo "✅ Keeping current Docker installation"
        echo "💡 The dotfiles will work with your current Docker"
        ;;
    2)
        echo "🔄 Backing up current Docker..."
        sudo mv /usr/bin/docker /usr/bin/docker.bak.$(date +%s)
        sudo mv /usr/share/bash-completion/completions/docker /usr/share/bash-completion/completions/docker.bak 2>/dev/null || true
        sudo mv /usr/share/fish/vendor_completions.d/docker.fish /usr/share/fish/vendor_completions.d/docker.fish.bak 2>/dev/null || true
        
        echo "📦 Installing Docker via pacman..."
        sudo pacman -S --noconfirm docker
        echo "✅ Docker reinstalled via pacman"
        ;;
    3)
        echo "⚡ Force overwriting with pacman..."
        sudo pacman -S --overwrite /usr/bin/docker,/usr/share/bash-completion/completions/docker,/usr/share/fish/vendor_completions.d/docker.fish --noconfirm docker
        echo "✅ Docker overwritten by pacman"
        ;;
    *)
        echo "❌ Invalid option"
        exit 1
        ;;
esac

# Configure Docker service
echo "🔧 Configuring Docker service..."
sudo systemctl enable docker.service
sudo systemctl start docker.service

# Add user to docker group
if ! groups | grep -q docker; then
    echo "👤 Adding user to docker group..."
    sudo usermod -aG docker $USER
    echo "✅ User added to docker group"
    echo "💡 You may need to log out and back in for group changes to take effect"
else
    echo "✅ User is already in docker group"
fi

echo ""
echo "🎉 Docker configuration complete!"
echo "Run: docker --version"
echo "Test: docker run hello-world"