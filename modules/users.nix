{ pkgs, ... }:
{
  users.users.janos = {
    isNormalUser = true;
    description = "János Euler";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [ ];
  };
  programs.firefox.enable = true;
  hardware.bluetooth.enable = true;
}
