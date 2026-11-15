{
  sops = {
    defaultSopsFile = ../secrets/secrets.yaml;
    age.keyFile = "/home/janos/.config/sops/age/keys.txt";
  };
  services.power-profiles-daemon.enable = true;
  services.upower.enable = true;
  services.printing.enable = true;
  virtualisation.docker.enable = true;
}
