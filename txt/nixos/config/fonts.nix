fonts.packages = with pkgs; [
  # Core font families
  jetbrains-mono
  noto-fonts
  noto-fonts-cjk-sans
  noto-fonts-color-emoji
  
  # Nerd Fonts for terminal/development
  nerd-fonts.jetbrains-mono
  nerd-fonts.fira-code
  nerd-fonts.droid-sans-mono
  nerd-fonts.symbols-only
];

fonts.fontconfig.antialias = true;
fonts.fontconfig.hinting = {
  enable = true;
  autohint = true;
};
