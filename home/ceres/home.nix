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
    # Typische Niri-Grundausstattung
    #xwayland-satellite # X11-Apps (Steam, Discord, ...)
    #nautilus           # oder nemo/thunar/dolphin
    pavucontrol        # Audio-Mixer
    #brightnessctl      # Helligkeit
    #wl-clipboard       # Clipboard im Terminal
    #playerctl          # Medientasten
    #adwaita-icon-theme
    #nerd-fonts.symbols-only  # Icons für Bars/Terminals

    spotify
  ];

  imports = [
    ./modules/niri.nix
  ];

  #programs.flyline.enable = true;

  home.shellAliases = {
    ls = "ls -hal --color=tty";
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

  programs.kitty = {
  enable = true;
  extraConfig = ''
    include themes/noctalia.conf
  '';
  };

  home.pointerCursor = {
    name = "Bibata-Modern-Classic";
    package = pkgs.bibata-cursors;
    size = 24;
    gtk.enable = true;
    x11.enable = true;
};
}