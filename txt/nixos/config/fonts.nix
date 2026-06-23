{ pkgs, ... }:

{
  # Enable system fonts directory to allow Flatpaks to read them
  fonts.fontDir.enable = true;

  # Core fonts for daily use, terminal, and emoji rendering
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-color-emoji
    
    # pkgs.nerdfonts has been deprecated/removed in recent NixOS/nixpkgs versions.
    # Individual fonts are now packaged under the `pkgs.nerd-fonts` attribute set.
    # You can list specific ones you want to install:
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
    nerd-fonts.droid-sans-mono
    nerd-fonts.symbols-only
  ];

  # Note: If you want to install ALL nerd fonts (very large), uncomment the following line:
  # fonts.packages = with pkgs; [ noto-fonts noto-fonts-cjk-sans noto-fonts-emoji fira-code ] ++ (builtins.filter pkgs.lib.isDerivation (builtins.attrValues pkgs.nerd-fonts));
}
