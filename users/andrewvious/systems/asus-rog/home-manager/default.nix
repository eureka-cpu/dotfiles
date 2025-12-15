{
 pkgs,
 ...
}: let
  xfcePath = ../xfce;
  xfceXml = "{$xfcePath}";
in {
  imports = [
    ./gtk.nix
    ../../../home-manager/default.nix
    ../../../home-manager/xfce.nix
  ];

  home.packages = with pkgs; [
    nvtopPackages.full
    melonDS
  ];

  programs.kitty = {
    themeFile = "kanagawabones";
    font.name = "JetBrainsMono Nerd Font";
  };

  programs.helix.settings.theme = "kanabox_default";

  programs.zsh.oh-my-zsh.theme = "dst";

  xdg.configFile = {
    "xfce4/xfconf/xfce-perchannel-xml/xfce4-keyboard-shortcuts.xml".source = "{xfceXml}/xfce4-keyboard-shortcuts.xml";
  };

  home.activation.applyXfceTweaks = lib.hm.dag.entryAfter ["writeBoundary"] ''
    ${pkgs.xfce.xfdesktop}/bin/xfdesktop --reload
  '';

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "25.05"; # Please read the comment before changing.
}
