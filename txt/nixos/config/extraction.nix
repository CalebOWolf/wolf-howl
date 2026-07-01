{ pkgs, ... }:

{
  # File extension extraction and archiving programs
  environment.systemPackages = with pkgs; [
    unar
    unzip
    p7zip
    lz4
    zstd
    xz
    lrzip
    brotli
    karchive
    ark
  ];
}
