#!/bin/bash

# Discord RPC Enabler Script for Fedora Linux
# This script enables Discord Rich Presence Communication (RPC) support
# Author: Generated for wolf-howl repository
# Date: November 2025

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root
if [[ $EUID -eq 0 ]]; then
    print_error "This script should not be run as root for security reasons."
    print_status "Please run as a regular user. The script will use sudo when needed."
    exit 1
fi

print_status "Discord RPC Enabler for Fedora Linux"
echo "======================================"

# Check if Discord is installed
check_discord() {
    print_status "Checking for Discord installation..."
    
    if command -v discord &> /dev/null || command -v Discord &> /dev/null; then
        print_success "Discord found in PATH"
        return 0
    elif [ -f "/usr/bin/discord" ] || [ -f "/opt/discord/Discord" ]; then
        print_success "Discord installation detected"
        return 0
    elif flatpak list | grep -q "com.discordapp.Discord" 2>/dev/null; then
        print_success "Discord Flatpak installation detected"
        return 0
    else
        print_warning "Discord installation not detected"
        print_status "You may need to install Discord first"
        return 1
    fi
}

# Install necessary packages for RPC support
install_rpc_dependencies() {
    print_status "Installing RPC dependencies..."
    
    # Common packages needed for Discord RPC
    packages=(
        "dbus"
        "dbus-libs"
        "dbus-devel"
        "libX11"
        "libX11-devel"
        "libxcb"
        "libxcb-devel"
    )
    
    for package in "${packages[@]}"; do
        if ! rpm -q "$package" &>/dev/null; then
            print_status "Installing $package..."
            sudo dnf install -y "$package"
        else
            print_success "$package is already installed"
        fi
    done
}

# Configure D-Bus for Discord RPC
configure_dbus() {
    print_status "Configuring D-Bus for Discord RPC..."
    
    # Ensure D-Bus is running
    if ! systemctl --user is-active --quiet dbus; then
        print_status "Starting D-Bus user service..."
        systemctl --user start dbus
        systemctl --user enable dbus
    else
        print_success "D-Bus user service is already running"
    fi
    
    # Set environment variables for RPC
    RPC_ENV_FILE="$HOME/.config/environment.d/discord-rpc.conf"
    
    mkdir -p "$HOME/.config/environment.d"
    
    cat > "$RPC_ENV_FILE" << EOF
# Discord RPC Environment Variables
DISCORD_RPC_ENABLED=1
XDG_CURRENT_DESKTOP=\${XDG_CURRENT_DESKTOP:-GNOME}
EOF
    
    print_success "Discord RPC environment configuration created"
}

# Configure firewall if needed
configure_firewall() {
    print_status "Checking firewall configuration..."
    
    if systemctl is-active --quiet firewalld; then
        print_status "Firewalld is active, checking Discord RPC ports..."
        
        # Discord uses ports in the range 6463-6472 for RPC
        for port in {6463..6472}; do
            if ! sudo firewall-cmd --query-port=${port}/tcp --zone=public &>/dev/null; then
                print_status "Opening port $port for Discord RPC..."
                sudo firewall-cmd --add-port=${port}/tcp --zone=public --permanent
            fi
        done
        
        sudo firewall-cmd --reload
        print_success "Firewall configured for Discord RPC"
    else
        print_success "Firewalld not active, no firewall configuration needed"
    fi
}

# Create Discord RPC test script
create_test_script() {
    print_status "Creating Discord RPC test script..."
    
    TEST_SCRIPT="$HOME/.local/bin/test-discord-rpc"
    mkdir -p "$HOME/.local/bin"
    
    cat > "$TEST_SCRIPT" << 'EOF'
#!/bin/bash
# Discord RPC Test Script

echo "Testing Discord RPC connection..."

# Check if Discord is running
if pgrep -x "discord" > /dev/null || pgrep -x "Discord" > /dev/null; then
    echo "✓ Discord process is running"
else
    echo "✗ Discord is not running. Please start Discord first."
    exit 1
fi

# Check RPC socket
for port in {6463..6472}; do
    if netstat -tuln 2>/dev/null | grep -q ":$port "; then
        echo "✓ Discord RPC is listening on port $port"
        echo "Discord RPC is working correctly!"
        exit 0
    fi
done

echo "✗ Discord RPC socket not found"
echo "Discord RPC may not be working properly"
exit 1
EOF
    
    chmod +x "$TEST_SCRIPT"
    print_success "Test script created at $TEST_SCRIPT"
}

# Setup desktop environment specific configurations
configure_desktop_environment() {
    print_status "Configuring desktop environment for Discord RPC..."
    
    case "$XDG_CURRENT_DESKTOP" in
        "GNOME"|"gnome")
            print_status "Configuring for GNOME..."
            # GNOME specific configurations if needed
            ;;
        "KDE"|"kde")
            print_status "Configuring for KDE..."
            # KDE specific configurations if needed
            ;;
        "XFCE"|"xfce")
            print_status "Configuring for XFCE..."
            # XFCE specific configurations if needed
            ;;
        *)
            print_status "Generic desktop environment configuration..."
            ;;
    esac
    
    print_success "Desktop environment configuration completed"
}

# Main execution
main() {
    print_status "Starting Discord RPC setup for Fedora..."
    
    # Check Discord installation
    check_discord
    
    # Install dependencies
    install_rpc_dependencies
    
    # Configure D-Bus
    configure_dbus
    
    # Configure firewall
    configure_firewall
    
    # Configure desktop environment
    configure_desktop_environment
    
    # Create test script
    create_test_script
    
    print_success "Discord RPC setup completed successfully!"
    echo
    print_status "Next steps:"
    echo "1. Restart Discord (if it's currently running)"
    echo "2. Log out and log back in (or reboot) to apply environment changes"
    echo "3. Run 'test-discord-rpc' to verify RPC is working"
    echo "4. Your applications should now be able to use Discord Rich Presence"
    echo
    print_warning "Note: Some applications may require additional configuration"
    print_status "Check the application's documentation for Discord RPC setup instructions"
}

# Run main function
main "$@"