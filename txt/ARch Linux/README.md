# 🐺 Wolf Howl - Arch Linux Gaming & Productivity Setup

**A complete automated post-installation script for Arch Linux that transforms a fresh system into a fully-configured gaming and productivity powerhouse, specifically optimized for AMD Ryzen 5700X and RX 6600 XT hardware.**

This isn't just another package installer - it's a comprehensive system transformation that sets up everything from low-level hardware optimization to high-level application integration, creating a seamless desktop experience ready for gaming, content creation, and daily productivity work.

## ⚠️ IMPORTANT DISCLAIMERS

### 🚨 USE AT YOUR OWN RISK

**THE AUTHOR IS NOT RESPONSIBLE FOR ANY DAMAGES, DATA LOSS, OR SYSTEM ISSUES THAT MAY RESULT FROM USING THIS SCRIPT.**

This script:
- Makes significant system modifications
- Installs packages from official repositories, AUR, and Flatpak
- Modifies system configurations and services
- Changes user permissions and desktop settings
- May conflict with existing software or configurations

### 📋 Before Running This Script

**MANDATORY PRECAUTIONS:**
1. **BACKUP YOUR DATA** - Always backup important files before running system modification scripts
2. **TEST FIRST** - Run in a virtual machine or test environment before using on your main system
3. **FRESH INSTALL RECOMMENDED** - Designed for fresh Arch Linux installations
4. **UNDERSTAND THE CHANGES** - Review the script to understand what it does
5. **ACCEPT RESPONSIBILITY** - You are fully responsible for any consequences

## 🎯 The Complete Gaming & Productivity Transformation

This script transforms a bare-bones Arch Linux installation into a complete, ready-to-use system that excels at:

### 🎮 **Gaming Excellence**
- **Optimal AMD Performance**: Full driver stack for Ryzen 5700X CPU and RX 6600 XT GPU
- **Game Launchers**: Steam with Proton, Lutris for non-Steam games, GameMode optimization
- **Mod Support**: Gale mod manager for Baldur's Gate 3 with automatic game detection
- **Rich Presence**: Discord integration showing what games you're playing
- **Hardware Acceleration**: Full Vulkan and Mesa support for maximum performance

### 💼 **Productivity Powerhouse**  
- **Office Suite**: LibreOffice Fresh with full document compatibility
- **Web & Communication**: Firefox, Discord with screensharing, Telegram with system integration
- **Security**: 1Password with browser integration and CLI tools
- **Development**: Visual Studio Code with essential development tools
- **Media Creation**: GIMP, Krita, Blender, OBS Studio, Kdenlive

### 🖥️ **Desktop Integration Perfection**
- **Wayland Native**: Optimized for modern desktop environments with X11 fallback
- **System Tray**: Applications properly integrate with system tray and notifications
- **File Handling**: Automatic file associations, drag-and-drop support, MIME types
- **Screensharing**: Full desktop portal support for Discord, OBS, and other applications
- **Auto-Updates**: Intelligent update management for Flatpak, AUR, and system packages

### ⚡ **Under-the-Hood Optimizations**
- **Multilib Support**: Enables 32-bit compatibility for gaming and legacy applications
- **AMD Microcode**: Latest CPU microcode for stability and security
- **PipeWire Audio**: Modern audio stack with low latency and professional features
- **Performance Tuning**: CPU governors, power management, and gaming optimizations
- **Package Management**: Aura AUR helper for seamless community package installation

### 🔧 **Smart Automation Features**
- **Conflict Resolution**: Automatically removes conflicting packages and configurations
- **Error Recovery**: Continues installation even if individual packages fail
- **Package Validation**: Verifies package availability before installation attempts
- **System Verification**: Pre-flight checks ensure system compatibility
- **User Guidance**: Detailed post-installation instructions and usage tips

## 🚀 Installation

### Prerequisites
- Fresh Arch Linux installation with base system
- Internet connectivity
- User account with sudo privileges  
- At least 5GB free disk space

### Quick Start
```bash
# Download the script
wget https://raw.githubusercontent.com/CalebOWolf/wolf-howl/main/txt/Arch%20Linux/arch-linux-script.sh

# Make executable
chmod +x arch-linux-script.sh

# Run the script
./arch-linux-script.sh

# Follow the prompts and reboot when complete
```

### What to Expect
- **Duration**: 30-60 minutes for complete transformation
- **Downloads**: ~3-5GB of carefully curated software
- **Reboot**: Required to activate all optimizations
- **Result**: A fully-configured system ready for gaming, work, and creativity

### Who This Script Is For
- **Gamers** wanting optimal AMD performance with modern game launchers
- **Content Creators** needing professional media tools and streaming setup  
- **Developers** requiring a complete development environment
- **Productivity Users** who want seamless communication and office tools
- **Arch Enthusiasts** who prefer automation over manual configuration

## 📖 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## ⚖️ Legal Notice

THIS SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

## 🤝 Contributing

Contributions are welcome! Please:
1. Test changes thoroughly
2. Update documentation as needed
3. Follow existing code style
4. Include appropriate error handling

## 📞 Support

- **Issues**: Report bugs via GitHub Issues
- **Discussions**: Use GitHub Discussions for questions
- **No Warranty**: This is free software with no guaranteed support

## 🔍 Verification

The script includes validation tools:
- `validate-script.sh` - Syntax and structure validation
- `readiness-report.sh` - Comprehensive readiness assessment

## 🚀 Your Transformed System

After the Wolf Howl transformation, you'll have:

### 🎮 **Ready-to-Game Setup**
- Launch Steam and your library works immediately with Proton
- Lutris configured for GOG, Epic, and other game launchers  
- Gale mod manager ready for Baldur's Gate 3 modding
- Discord with rich presence showing your gaming activity

### 💼 **Instant Productivity**
- 1Password integrated with all browsers for secure password management
- LibreOffice ready for documents, spreadsheets, and presentations
- Telegram with system tray for seamless communication
- VS Code configured with essential development extensions

### 🖥️ **Perfect Desktop Integration**
- Applications start in system tray and show proper notifications
- File associations work - double-click files to open in correct applications
- Screensharing works in Discord, OBS, and video calls
- Hardware acceleration enabled for smooth performance

### 🔧 **Maintenance Made Easy**
Update your system with simple commands:
```bash
# Update AUR packages (includes Gale, 1Password, VS Code)
aura -Au

# Update Flatpak applications (Discord, Telegram)
flatpak update

# Update system packages
sudo pacman -Syu
```

### 🎯 **What Makes This Special**
Unlike other Arch setup scripts that just install packages, Wolf Howl creates a **cohesive ecosystem** where everything works together seamlessly - from low-level AMD optimizations to high-level application integration.

---

**🐺 Remember: You use this script entirely at your own risk. Always backup important data and test in a safe environment first. The Wolf Howl is powerful, but responsibility lies with the user.**