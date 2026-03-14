{ config, lib, pkgs, brave-torrent, ... }:

let
  bravePkgs = import brave-torrent {
    system = pkgs.system;
    config.allowUnfree = true;
  };

  profileDir = "${config.home.homeDirectory}/.config/brave-torrent";
in
{
  options.braveTorrent.enable =
    lib.mkEnableOption "Pinned Brave 1.77.101 for web torrent usage";

  config = lib.mkIf config.braveTorrent.enable {

    home.packages = [
      (bravePkgs.writeShellScriptBin "brave-torrent" ''
        exec ${bravePkgs.brave}/bin/brave \
          --user-data-dir=${profileDir} \
          --disable-brave-update \
          "$@"
      '')
    ];

    xdg.desktopEntries.brave-torrent = {
      name = "Brave Torrent";
      comment = "Brave 1.77.101 (legacy web torrent support)";
      exec = "brave-torrent %U";
      icon = "brave-browser";
      terminal = false;
      categories = [ "Network" "WebBrowser" ];
    };
  };
}
