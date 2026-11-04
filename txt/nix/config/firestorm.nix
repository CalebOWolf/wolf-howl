{ lib
, stdenv
, fetchurl
, autoPatchelfHook
, makeWrapper
, alsa-lib
, at-spi2-atk
, cups
, expat
, glib
, libdrm
, libgbm
, libgcc
, libGLU
, libuuid
, libx11
, libxcomposite
, libxcrypt-legacy
, libxdamage
, libxkbcommon
, libxrandr
, libnotify
, nspr
, nss
, pango
, pulseaudio
, udev
}:

stdenv.mkDerivation {
  pname = "firestorm";
  version = "7.2.4";

  src = fetchurl {
    url = "https://downloads.firestormviewer.org/release/linux/Phoenix-Firestorm-Releasex64_AVX2-7-2-4-80712.tar.xz";
    hash = "sha256-QF/o/FmElNcRRaSOf+rj4fAvdJL3MBfu66b6B3pfIag=";
  };

  dontUnpack = true;
  dontBuild = true;

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = [
    alsa-lib
    at-spi2-atk
    cups.lib
    expat
    glib
    libdrm
    libgbm
    libgcc.lib
    libGLU
    libuuid
    libx11
    libxcomposite
    libxcrypt-legacy
    libxdamage
    libxkbcommon
    libxrandr
    nspr
    nss
    pango
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p "$out"
    tar --strip-components=1 -xf "$src" -C "$out"

    wrapProgram "$out/firestorm" \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [
        libnotify
        pulseaudio
        udev
      ]}"

    mkdir -p "$out/bin" "$out/share/applications"
    ln -s ../firestorm "$out/bin/firestorm"
    cat > "$out/share/applications/firestorm.desktop" <<EOF
    [Desktop Entry]
    Name=Firestorm Viewer
    Comment=Firestorm Viewer for Second Life
    Exec=$out/bin/firestorm
    Icon=$out/firestorm_icon.png
    Terminal=false
    Type=Application
    Categories=Game;
    EOF

    runHook postInstall
  '';

  meta = {
    description = "Viewer for the Second Life virtual world";
    homepage = "https://www.firestormviewer.org/";
    downloadPage = "https://www.firestormviewer.org/linux/";
    mainProgram = "firestorm";
    platforms = [ "x86_64-linux" ];
    license = lib.licenses.lgpl21Plus;
  };
}
