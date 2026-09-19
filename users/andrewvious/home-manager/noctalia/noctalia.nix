{ ... }:
{
  programs.noctalia.enable = true;
  xdg.configFile."noctalia/noctalia.toml".source = ./noctalia.toml;
}
