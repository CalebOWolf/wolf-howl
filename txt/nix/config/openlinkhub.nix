{ pkgs, ... }:

{
  users.groups.openlinkhub = { };
  users.users.openlinkhub = {
    isSystemUser = true;
    group = "openlinkhub";
  };

  services.udev.packages = [ pkgs.openlinkhub ];

  systemd.services.openlinkhub = {
    description = "OpenLinkHub hardware control service";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];

    preStart = ''
      ${pkgs.coreutils}/bin/cp -rn ${pkgs.openlinkhub}/opt/OpenLinkHub/. /var/lib/openlinkhub/
    '';

    serviceConfig = {
      User = "openlinkhub";
      Group = "openlinkhub";
      StateDirectory = "openlinkhub";
      WorkingDirectory = "/var/lib/openlinkhub";
      ExecStart = "${pkgs.openlinkhub}/bin/OpenLinkHub";
      Restart = "on-failure";
      RestartSec = "5s";
    };
  };
}
