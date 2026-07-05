{ pkgs, config, ... }:

{
  # 1. Permitted insecure packages (Required IF you are using Unity Editor versions older than 2022)
  nixpkgs.config.permittedInsecurePackages = [
    "openssl-1.1.1w" 
  ];

  environment.systemPackages = with pkgs; [
    # 2. Install Unity Hub with the OpenSSL fallback patch
    (unityhub.override {
      extraLibs = p: [ p.openssl_1_1 ];
    })
  ];
}
