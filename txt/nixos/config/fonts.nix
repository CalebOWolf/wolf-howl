{ pkgs, ... }:

{
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
      autohint = true;
    };
    
    # Define preferred fonts for different categories
    defaultFonts = {
      monospace = [ "JetBrains Mono Nerd Font" "Noto Sans Mono" ];
      sansSerif = [ "Noto Sans" "DejaVu Sans" ];
      serif = [ "Noto Serif" "DejaVu Serif" ];
    };
  };
}
