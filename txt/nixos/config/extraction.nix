{ pkgs, ... }:

{
  # Archive extraction and compression tools
  environment.systemPackages = with pkgs; [
    # CLI tools
    lz4      # LZ4 compression
    p7zip    # 7-Zip format support
    unar     # Universal archive extractor
    unzip    # ZIP extraction
    xz       # XZ compression
    zstd     # Zstandard compression
  ];
}
