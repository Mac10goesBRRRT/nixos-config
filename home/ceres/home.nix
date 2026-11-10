{ config, pkgs, inputs, ... }:
let
  flyline = inputs.flyline.packages.${pkgs.stdenv.hostPlatform.system}.flyline;
in
{
  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "24.11";

    imports = [
    ./modules/niri.nix
  ];

  #programs.flyline.enable = true;

  home.shellAliases = {
    ls = "ls -hal";
    cat = "bat";
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.bash = {
    enable = true;
    initExtra = ''
      enable -f ${flyline}/lib/libflyline.so flyline
      flyline mouse --mode disabled
    '';
  };
}