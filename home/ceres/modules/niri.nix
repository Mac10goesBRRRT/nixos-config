{
  config,
  lib,
  pkgs,
  ...
}:

let
  niriDefaultConfig = pkgs.runCommand "niri-default-config.kdl" { } ''
    sed -e '/^spawn-at-startup "waybar"$/d' \
      -e '/Mod+Shift+Slash/d' \
      -e '/Mod+BracketLeft/d' \
      -e '/Mod+BracketRight/d' \
      -e '/Mod+Equal/d' \
      -e '/Mod+Shift+Equal/d' \
      "${config.wayland.windowManager.niri.package.src}/resources/default-config.kdl" > "$out"
  '';
in
{
  programs.noctalia = {
    enable = true;
    settings = {
      # Beispiel aus der Doku, Pfad anpassen:
      wallpaper = {
        enabled = true;
        default.path = "/home/janos/Pictures/wallpaper.png";
      };
    };
  };
  wayland.windowManager.niri = {
    enable = true;
    extraConfig = lib.mkBefore ''
      include "${niriDefaultConfig}"
    '';
    settings = {
      input.keyboard.xkb.layout = "de";

      #output = {
      #  _args = [ "eDP-1" ];
      #  mode = "2880x1800@120.000";
      #};
      _children = [
        {
          spawn-at-startup._args = [ "noctalia" ];
        }
      ];
    };
  };
}