{ stdenv, fetchurl, lib, pkgs }:

let
  os = "linux";
  arch = "x64";
  version = "2.5.9";
  unpackDir = "HexcoreLink_${version}_${arch}";
in

stdenv.mkDerivation {
  pname = "hexcore-link";
  inherit version;

  src = fetchurl {
    url = "https://s5.hexcore.xyz/releases/software/hexcore-link/${os}/tar/HexcoreLink_${version}_${arch}.tar.gz";
    hash = "sha256-cm8gYtJEbSEB5rLuxeldGGwaChXiHt5p5f9XPsMNJOk=";
  };

  nativeBuildInputs = with pkgs; [
    autoPatchelfHook
    makeWrapper
    gdk-pixbuf
  ];

  buildInputs = with pkgs; [
    glib
    gtk3
    nss
    xdg-utils
    xdg-desktop-portal
    xdg-desktop-portal-gtk
    hicolor-icon-theme
    nspr
    xorg.libX11
    xorg.libXcomposite
    xorg.libXdamage
    xorg.libXext
    xorg.libXfixes
    xorg.libXrandr
    xorg.libxcb
    xorg.libXrender
    xorg.libXi
    alsa-lib
    dbus
    libdrm
    at-spi2-core
    expat
    libxkbcommon
    libglvnd
    udev
    mesa
    chromium
  ];

  # Unpacking the tarball
  unpackPhase = ''
    runHook preUnpack
    tar -xzf $src
    runHook postUnpack
  '';

  # Install phase: Copy the binary, create necessary directories, generate loaders cache
  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    mkdir -p $out/lib

    cp -r ./${unpackDir}/* $out/bin/
    mv $out/bin/hexcore-link $out/bin/hexcore-link-unwrapped

    # Patch the .so files with patchelf to ensure they can find each other
    for so_file in $out/bin/*.so; do
      patchelf --set-rpath $out/bin:$out/lib $so_file
    done

    # Wrap the binary so it can find icons and GTK deps
    makeWrapper $out/bin/hexcore-link-unwrapped $out/bin/hexcore-link \
      --set GDK_PIXBUF_MODULE_FILE "$out/loaders.cache" \
      --set XDG_DATA_DIRS "$out/share:${pkgs.shared-mime-info}/share:${pkgs.hicolor-icon-theme}/share" \
      --set XDG_CURRENT_DESKTOP "Hyprland" \
      --set XDG_SESSION_TYPE "wayland" \
      --set ELECTRON_ENABLE_WAYLAND "1" \
      --set ELECTRON_ENABLE_LOGGING "1" \
      --set ELECTRON_DISABLE_SANDBOX "true" \
      --set GTK_USE_PORTAL "0"

    runHook postInstall
  '';

  meta = {
    description = "Hexcore Link UI for managing Hexcore devices";
    homepage = "https://hexcore.xyz/";
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ eureka-cpu ];
  };
}
