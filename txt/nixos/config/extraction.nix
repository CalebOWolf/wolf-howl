{ pkgs, ... }:

{
  # File extension extraction and archiving programs
  environment.systemPackages = with pkgs; [
    7zip
    kdePackages.ark
    kdePackages.karchive
  ];
}
