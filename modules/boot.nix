{ pkgs, ... }:
{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.extraEntries."fedora-grub.conf" = ''
    title GRUB (Fedora/CachyOS)
    efi /EFI/fedora/shimx64.efi
  '';
  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.kernelParams = [ "quiet" ];
  boot.consoleLogLevel = 3;

  acidBoot = {
    enable = true;
    retainSplash = true;
    palette = "cool-gray";
    logoFile = ../home/ceres/assets/flake.png;
  };
}
