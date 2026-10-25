{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Universal archive extraction
    unar      # Supports most archive formats

    # Archive creation/extraction
    gnutar    # tar utility for .tar and compressed tar archives

    # Compression/decompression tools
    bzip2
    gzip
    lz4
    p7zip     # 7-Zip format support
    zip       # Create .zip archives
    unzip
    unrar     # Better compatibility for some .rar archives
    xz        # LZMA compression
    zstd      # Modern compression algorithm
  ];
}
