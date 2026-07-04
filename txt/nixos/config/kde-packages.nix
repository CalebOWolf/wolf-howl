{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Core Desktop Environment
    kdePackages.kwin
    kdePackages.krunner
    kdePackages.kwallet
    kdePackages.kscreen
    kdePackages.breeze
    kdePackages.oxygen
    kdePackages.oxygen-icons
    kdePackages.oxygen-sounds

    # File & System Management
    kdePackages.dolphin
    kdePackages.kdf
    kdePackages.kup
    kdePackages.kbackup

    # Development & Utilities
    kdePackages.kate
    kdePackages.konsole
    kdePackages.kdialog
    kdePackages.kfind
    kdePackages.kompare
    kdePackages.kpmcore

    # Media & Graphics
    kdePackages.gwenview
    kdePackages.elisa
    kdePackages.kasts
    kdePackages.dragon
    kdePackages.audex
    kdePackages.kwave
    kdePackages.koko

    # Communication
    kdePackages.kontact  # Includes kmail, kaddressbook, etc.
    kdePackages.kpeople

    # Internet
    kdePackages.falkon
    kdePackages.krdc
    kdePackages.krfb
    kdePackages.kget

    # Tools & Accessories
    kdePackages.kcalc
    kdePackages.kcron
    kdePackages.kalarm
    kdePackages.ktimer
    kdePackages.kgpg
    kdePackages.kmag
    kdePackages.kruler
    kdePackages.kzones
    kdePackages.kmix
    kdePackages.timed

    # Games (optional - consider removing if not used)
    kdePackages.kmines
    kdePackages.kbounce
    kdePackages.kblocks
    kdePackages.kpat
    kdePackages.khangman
    kdePackages.kapman
    kdePackages.kolf
    kdePackages.knights
    kdePackages.ktorrent

    # Diagnostics & System
    kdePackages.drkonqi
    kdePackages.kcrash
    kdePackages.discover
  ];
}
