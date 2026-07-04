{ pkgs, ... }:

{
  # Enable system fonts directory to allow Flatpaks to read them
  fonts.fontDir.enable = true;

  # Define default fonts for different categories
  fonts.fontconfig.enable = true;
  fonts.fontconfig.defaultFonts = {
    monospace = [ "JetBrains Mono" ];
    sansSerif = [ "Noto Sans" ];
    serif = [ "Noto Serif" ];
    emoji = [ "Noto Color Emoji" ];
  };

  # Core fonts for daily use, terminal, and emoji rendering
  fonts.packages = with pkgs; [
    # Sans serif and CJK support
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    
    # Nerd Fonts - Individual fonts instead of the deprecated pkgs.nerdfonts
    # (Recent NixOS/nixpkgs versions package these under pkgs.nerd-fonts)
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
    nerd-fonts.droid-sans-mono
    nerd-fonts.symbols-only
  ];

  # Alternative: to install ALL nerd fonts (very large download):
  # fonts.packages = with pkgs; [ noto-fonts noto-fonts-cjk-sans noto-fonts-color-emoji ] 
  #   ++ (builtins.filter pkgs.lib.isDerivation (builtins.attrValues pkgs.nerd-fonts));
}
