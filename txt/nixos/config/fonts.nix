{ pkgs, ... }:

{
  # Keep core defaults available and expose fonts for older toolkits/apps.
  fonts.enableDefaultPackages = true;
  fonts.fontDir.enable = true;

  fonts.packages = with pkgs; [
    # Core font families
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    
    # Nerd Fonts for terminal/development (includes base fonts)
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
    nerd-fonts.droid-sans-mono
    nerd-fonts.symbols-only
  ];

  fonts.fontconfig = {
    antialias = true;
    hinting = {
      enable = true;
      autohint = false;
      style = "slight";
    };
    subpixel = {
      rgba = "rgb";
      lcdfilter = "default";
    };
    
    # Define preferred fonts for different categories
    defaultFonts = {
      monospace = [ "JetBrains Mono Nerd Font" "Noto Sans Mono" ];
      sansSerif = [ "Noto Sans" "DejaVu Sans" ];
      serif = [ "Noto Serif" "DejaVu Serif" ];
      emoji = [ "Noto Color Emoji" ];
    };
  };
}
