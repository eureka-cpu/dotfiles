{ pkgs, ... }: {
  systemd.services.thermal-throttle = {
    description = "Userspace CPU thermal throttle for Snapdragon X Elite";
    wantedBy = ["multi-user.target"];

    script = ''
      ${pkgs.python3}/bin/python3 ${./thermal-throttle.py}
    '';

    serviceConfig = {
      Type = "simple";
      Restart = "always";
      RestartSec = 5;
    };
  };  
}
