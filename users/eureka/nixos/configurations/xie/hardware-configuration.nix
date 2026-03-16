{ config, lib, pkgs, modulesPath, ... }:
{
  hardware.lenovo-yoga-slim7x.enable = true;

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/root";
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/disk/by-label/SYSTEM_DRV";
      fsType = "vfat";
    };
  };

  # Enable some SysRq keys (80 = sync + process kill)
  # See: https://docs.kernel.org/admin-guide/sysrq.html
  boot.kernel.sysctl."kernel.sysrq" = 80;
  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
}
