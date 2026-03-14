{
  # Enable power management.
  services = {
    auto-cpufreq.enable = true;
    tlp.enable = true;
    power-profiles-daemon.enable = false;
  };
}
