final: prev: {
  brave-torrent =
prev.brave-torrent.overrideAttrs {
    version = "1.77.101";
    src = prev.fetchurl {
      url = "https://github.com/brave/brave-browser/releases/download/v${version}/brave-browser_${version}_arm64.deb";
      sha256 = "sha256-mRbRGCsvkrNVfwYrlfgGyU94dEezFTI/ittkbVynp7Q=";
    };
  };
}
