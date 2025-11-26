# Fedora Installation Script

This folder contains a comprehensive Fedora installation script tailored for systems with AMD Ryzen 5700X and Nvidia 5060 hardware. The script automates the setup of essential tools, drivers, and applications for general use, gaming, and content creation. It also includes desktop customization for KDE Plasma and expanded font/emoji support.

## Features

- **System Updates**: Ensures the system is up-to-date with the latest packages.
- **Essential Tools**: Installs a variety of utilities for productivity and system management.
- **RPM Fusion & Multimedia**: Enables RPM Fusion (free, nonfree, tainted), Cisco OpenH264, swaps `ffmpeg-free` → `ffmpeg`, and installs codecs.
- **Driver Setup**: Configures AMD drivers (freeworld VA/VDPAU swaps) and installs firmware bundles.
- **Gaming Focus**: Installs Gamemode, Gamescope, MangoHud, Proton/Wine helpers, Steam device support, and required 32‑bit libraries; auto‑enables `gamemoded`.
- **Flatpak Integration**: Sets up Flathub and optionally installs Heroic, Bottles, and ProtonUp‑Qt.
- **Specific RPM Apps**: Adds official repositories and installs 1Password and Visual Studio Code.
- **Fonts & Emoji**: Installs Noto/monospace fonts, emoji packs, Microsoft core fonts; optional import of MS Sans Serif from a Windows partition or a user folder.
- **KDE Plasma Customization**: Applies Papirus icons, Breeze Dark base, aligns GTK themes, sets MS Sans Serif as the UI font, and configures a Kvantum "Win7Glass" Aero‑style theme (with customizable glow color, default `#00FF7F`).
- **Quality of Life**: Enables sudo password feedback (`pwfeedback`), applies tuned performance profiles for Ryzen, and performs final cleanup.
- **Error Handling & Logging**: Centralized logging (`fedora-setup.log`) and guarded steps with informative errors.

## Usage

1. Clone this repository or download the script.
2. Ensure the script has executable permissions:
   ```bash
   chmod +x txt/fedora/fedora-install-script.sh
   ```
3. Run the script (sudo may be prompted automatically by individual steps):
   ```bash
   ./txt/fedora/fedora-install-script.sh
   ```

### Optional: MS Sans Serif fonts

To use MS Sans Serif across KDE/GTK, provide the font files before running the script:

- Place `micross.ttf` and/or `sserif*.ttf` in `~/MSSansFonts` or mount your Windows partition so the script can copy from `/mnt/c/Windows/Fonts` or `/run/media/$USER/<drive>/Windows/Fonts`.
- The script will import the fonts to `~/.local/share/fonts/MSSansSerif` and refresh caches automatically.

## Disclaimer

This script is provided "AS IS" without any warranties or guarantees. The author assumes no responsibility for any data loss, irreversible changes, or damage to your system resulting from the use of this script. Use it at your own risk and ensure you have proper backups before proceeding.

## Contributions

Suggestions for improvement can be made by opening an issue or submitting a pull request on the [GitHub repository](https://github.com/CalebOWolf/wolf-howl).

## License

Copyright © 2025 CalebOWolf/Caleb Mignano. All rights reserved.