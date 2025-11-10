# 🐧 Fedora Linux Resources

This directory contains Fedora Linux-specific setup scripts, configuration guides, and personal notes for streamlined system installation and maintenance.

## 📁 Directory Contents

```
fedora/
├── 📋 README.md                 # This documentation file
├── 🚀 fedora-install-script.sh  # Automated post-installation setup script (v2.0)
├── 🔍 validate-script.sh        # Script validation and testing tool
├── 📦 rpm-fusion.txt            # RPM Fusion repository setup commands
└── 📝 notes.txt                 # Personal installation notes and tips
```

## 🚀 Quick Start

### **New Fedora Installation**
1. **Validate the script**: `./validate-script.sh` *(recommended)*
2. **Run the install script**: `./fedora-install-script.sh`
3. **Review the log**: Check generated log file for any issues
4. **Reboot system**: Ensure all changes take effect

### **RPM Fusion Setup** *(Fedora 43 Compatible)*
```bash
# Enable RPM Fusion repositories (supports current Fedora versions)
sudo dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
```
*See `rpm-fusion.txt` for complete setup commands*

## 📦 File Descriptions

### **`fedora-install-script.sh`** - Automated Setup *(Version 2.0)*
**Purpose**: Comprehensive post-installation configuration for AMD Ryzen + Radeon systems

**✨ Key Features**:
- **🛡️ Comprehensive error handling** - Robust error detection and recovery
- **📊 Detailed logging** - Complete installation log with timestamps
- **🎯 Modular design** - Organized functions for different installation phases
- **⚠️ User confirmation** - Interactive prompts before major changes
- **🔍 Requirement validation** - Pre-flight checks for system compatibility
- **📈 Progress reporting** - Real-time status updates and final summary

**🔧 Installation Components**:
- **System Updates**: Full system upgrade with kernel headers
- **RPM Fusion Setup**: Multimedia codecs and proprietary drivers
- **AMD Optimization**: CPU frequency scaling and GPU driver setup
- **Development Tools**: Essential packages for coding and system administration
- **Gaming Support**: Steam, Lutris, 32-bit libraries, and gaming tools
- **Creative Applications**: OBS, Blender, GIMP, Kdenlive, and more
- **External Applications**: Chrome, VS Code, 1Password via direct download
- **Flatpak Applications**: 30+ applications across multiple categories

**🚀 Usage**:
```bash
# Make executable (if needed)
chmod +x fedora-install-script.sh

# Run with comprehensive error handling
./fedora-install-script.sh

# View installation log
less /tmp/fedora-setup-YYYYMMDD-HHMMSS.log
```

**🔍 Validation** *(New in v2.0)*:
```bash
# Validate script before running
./validate-script.sh
```

### **`rpm-fusion.txt`** - Repository Configuration  
**Purpose**: Enables additional software repositories for multimedia and proprietary drivers

**What it provides**:
- ✅ **Multimedia codecs** - Video/audio format support
- ✅ **Graphics drivers** - NVIDIA and AMD proprietary drivers  
- ✅ **Additional software** - Steam, Discord, and other applications
- ✅ **Firmware packages** - Hardware-specific firmware updates
- ✅ **Fedora 43+ compatibility** - Dynamic version detection

**Key commands covered**:
- RPM Fusion free and non-free repository installation
- Cisco OpenH264 codec enablement
- Multimedia package installation
- Firmware package setup

### **`validate-script.sh`** - Script Validation Tool *(New in v2.0)*
**Purpose**: Validates the main installation script without making system changes

**🔍 Validation Features**:
- **Syntax checking** - Ensures script has no bash syntax errors
- **ShellCheck analysis** - Advanced static analysis (if ShellCheck installed)
- **URL accessibility** - Verifies all download links are working
- **Permission validation** - Checks script has proper execute permissions
- **Fedora compatibility** - Confirms running on supported Fedora version
- **Comprehensive reporting** - Detailed validation summary with recommendations

**Usage**:
```bash
./validate-script.sh  # Run all validation checks
```

### **`notes.txt`** - Personal Documentation
**Purpose**: Personal installation notes, troubleshooting tips, and configuration reminders

**Likely contains**:
- Installation gotchas and solutions
- Personal preferences and tweaks
- Hardware-specific configurations
- Post-installation checklist items

## 🎯 Use Cases

### **Fresh Installation**
Perfect for setting up a new Fedora system with:
- Automated package installation
- Multimedia codec support
- Development environment preparation
- Personal configuration preferences

### **System Migration**  
Helpful when moving to a new machine:
- Consistent environment setup
- Documented configuration steps
- Tested command sequences
- Personal notes and reminders

### **Learning Resource**
Educational value for:
- Understanding Fedora package management
- Learning RPM Fusion integration
- System administration practices
- Linux configuration management

## 🔧 Technical Details

### **Compatibility**
- **Primary target**: Fedora Linux (latest versions)
- **Tested on**: Fedora 43+ (as confirmed compatible)
- **Architecture**: Likely supports x86_64 systems
- **Package manager**: DNF (Fedora's default)

### **Requirements**
- Fresh or existing Fedora installation
- Internet connection for package downloads
- sudo/root access for system modifications
- Basic terminal/command line familiarity

### **Safety & Error Handling** *(Enhanced in v2.0)*
- ⚠️ **Pre-flight validation** - Automatic system requirement checks
- 🛡️ **Graceful error recovery** - Script continues despite minor failures
- 📝 **Comprehensive logging** - Detailed logs for troubleshooting
- 🔄 **Backup important data** - Before major system changes
- 🧪 **Test validation first** - Run `validate-script.sh` before installation
- 📋 **Interactive confirmations** - User approval before major changes

## 🌟 Benefits

### **Time Saving**
- **Automated setup** reduces manual configuration time
- **Tested commands** prevent common installation errors
- **Personal notes** capture lessons learned from experience

### **Consistency**
- **Reproducible environment** across multiple installations
- **Documented process** ensures nothing is forgotten
- **Version controlled** changes tracked over time

### **Knowledge Sharing**
- **Educational resource** for other Fedora users
- **Best practices** documented and shared
- **Community contribution** to Fedora ecosystem

## 🔗 Related Resources

### **Official Documentation**
- [Fedora Documentation](https://docs.fedoraproject.org/)
- [RPM Fusion Configuration](https://rpmfusion.org/Configuration)
- [DNF Package Manager Guide](https://dnf.readthedocs.io/)

### **Repository Context**  
- **Main README**: [../../README.md](../../README.md) - Full project overview
- **Text Files**: [../README.md](../README.md) - Parent directory documentation
- **Contributing**: [../../CONTRIBUTING.md](../../CONTRIBUTING.md) - Contribution guidelines

## 📞 Support & Questions

If you have questions about these Fedora resources:
- **Check the notes**: `notes.txt` may have relevant troubleshooting info
- **Test in VM**: Try scripts in a virtual machine first
- **Contact maintainer**: See main repository for contact information
- **Community forums**: Fedora community forums for general Linux questions

---

*These resources represent real-world Fedora setup experience and are maintained for personal use and educational sharing. Use at your own discretion and always understand what scripts do before running them.*