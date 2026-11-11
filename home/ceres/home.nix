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

  
  home.packages = with pkgs; [
    kitty
    pavucontrol        # Audio-Mixer
    eza
    spotify
    nerd-fonts.fira-code
  ];

  fonts.fontconfig.enable = true;

  imports = [
    ./modules/niri.nix
    ./modules/shell.nix
  ];

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

  programs.kitty = {
    enable = true;
    extraConfig = ''
      include themes/noctalia.conf
    '';
    font = {
      name = "FiraCode Nerd Font";
      size = 12;
    };
  };

  home.pointerCursor = {
    enable = true;
    name = "Bibata-Modern-Classic";
    package = pkgs.bibata-cursors;
    size = 24;
    gtk.enable = true;
    x11.enable = true;
};
}