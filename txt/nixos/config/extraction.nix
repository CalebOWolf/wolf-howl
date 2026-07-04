{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Universal archive extraction
    unar      # Supports most archive formats

    # Compression/decompression tools
    bzip2
    gzip
    lz4
    p7zip     # 7-Zip format support
    unzip
    xz        # LZMA compression
    zstd      # Modern compression algorithm
  ];
}
