{ pkgs, ... }:

{
  # File extension extraction and archiving programs
  environment.systemPackages = with pkgs; [
    _7zz
    kdePackages.ark
    kdePackages.karchive
  ];
}
