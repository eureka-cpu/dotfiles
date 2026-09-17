{ pkgs, ... }: 
{
  programs.fastfetch = {
  enable = true;
  settings = {
    logo = {
      type = "builtin";
      source = "nixos_small";
      padding = {
        top = 2;
        left = 3;
      };
    };
    modules = [
      "break"
      {
        type = "custom";
        format = "┌──────────────────────Hardware──────────────────────┐";
      }
      {
        type = "host";
        key = "┌  Host";
        keyColor = "32";
      }
      {
        type = "cpu";
        key = "├  CPU";
        keyColor = "32";
        temp = true;
      }
      {
        type = "cpuusage";
        key = "├  Usage";
        keyColor = "32";
      }
      {
        type = "command";
        key = "├  Load";
        keyColor = "32";
        text = "awk '{print \"1m: \"$1\" | 5m: \"$2\" | 15m: \"$3}' /proc/loadavg";
      }
      {
        type = "gpu";
        key = "├  GPU";
        keyColor = "32";
        temp = true;
      }
      {
        type = "memory";
        key = "├  RAM";
        keyColor = "32";
      }
      {
        type = "disk";
        key = "└ System";
        keyColor = "32";
        folders = "/";
      }
      {
        type = "custom";
        format = "└────────────────────────────────────────────────────┘";
      }
      "break"
      {
        type = "custom";
        format = "┌──────────────────────Software──────────────────────┐";
      }
      {
        type = "os";
        key = "┌  OS";
        keyColor = "35";
      }
      {
        type = "kernel";
        key = "├  Kernel";
        keyColor = "35";
      }
      {
        type = "wm";
        key = "├  WM";
        keyColor = "35";
      }
      {
        type = "terminal";
        key = "├  Terminal";
        keyColor = "35";
      }
      {
        type = "packages";
        key = "├  Packages";
        keyColor = "35";
      }
      {
        type = "shell";
        key = "└  Shell";
        keyColor = "35";
      }
      {
        type = "custom";
        format = "└────────────────────────────────────────────────────┘";
      }
      "break"
      {
        type = "custom";
        format = "┌──────────────────────Network───────────────────────┐";
      }
      {
        type = "localip";
        key = "┌  IP";
        keyColor = "33";
      }
      {
        type = "dns";
        key = "├  DNS";
        keyColor = "33";
      }
      {
        type = "netio";
        key = "├  Net I/O";
        keyColor = "33";
      }
      {
        type = "uptime";
        key = "└  Uptime";
        keyColor = "33";
      }
      {
        type = "custom";
        format = "└────────────────────────────────────────────────────┘";
      }
      {
        type = "colors";
        paddingLeft = 2;
        symbol = "circle";
      }
    ];
  };
};
}
