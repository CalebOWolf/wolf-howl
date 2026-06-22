{ pkgs, ... }:

{
  # Enable system fonts directory to allow Flatpaks to read them
  fonts.fontDir.enable = true;

  # Core fonts for daily use, terminal, and emoji rendering
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
    fira-code
    nerdfonts
  ];
}
