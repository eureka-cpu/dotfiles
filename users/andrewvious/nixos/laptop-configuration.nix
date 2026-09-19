{
  services = {
    # Power management
    power-profiles-daemon.enable = true;
    # Battery statistics
    upower.enable = true;
    # USB drive automounting
    udisks2.enable = true;  
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
}
