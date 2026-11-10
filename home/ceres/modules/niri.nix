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
      theme = {
        mode = "auto";
        source = "wallpaper";
        builtin = "Noctalia";
      };

      shell = {
        font_family = "Fira Code";
        polkit_agent = true;
        panel.transparency_mode = "glass";
      };

      cursor = {
        theme = "Bibata-Modern-Classic";
        size = 24;
      };

      backdrop = {
        enabled = false;
        blur_intensity = 0.5;
        tint_intensity = 0.3;
      };

      idle.behavior.lock = {
        timeout = 300;
        action = "lock";
        enabled = true;
      };

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

      output = {
        _args = [ "eDP-1" ];
        mode = "1920x1080@60.000";
        scale = 1.0;
      };


      binds = {
        "Mod+T" = {
          _props.hotkey-overlay-title = "Open a Terminal";
          spawn = [ "kitty" ];
        };
        "Mod+L" = {
          _props.hotkey-overlay-title = "Lock the Screen";
          spawn-sh = "noctalia msg session lock";
        };

        "Mod+Plus".set-column-width = "+10%";
        "Mod+Minus".set-column-width = "-10%";
        "Mod+Shift+Plus".set-window-height = "+10%";
        "Mod+Shift+Minus".set-window-height = "-10%";

        "Alt+Tab".spawn-sh = "noctalia msg window-switcher";
        "Print".spawn-sh = "noctalia msg screenshot-region";
        "Mod+Print".spawn-sh = "noctalia msg screenshot-fullscreen";

        "Mod+Space".spawn-sh = "noctalia msg panel-toggle launcher";

        "XF86AudioRaiseVolume" = {
          _props.allow-when-locked = true;
          spawn-sh = "noctalia msg volume-up";
        };
        "XF86AudioLowerVolume" = {
          _props.allow-when-locked = true;
          spawn-sh = "noctalia msg volume-down";
        };
        "XF86AudioMute" = {
          _props.allow-when-locked = true;
          spawn-sh = "noctalia msg volume-mute";
        };
        "XF86MonBrightnessUp" = {
          _props.allow-when-locked = true;
          spawn-sh = "noctalia msg brightness-up";
        };
        "XF86MonBrightnessDown" = {
          _props.allow-when-locked = true;
          spawn-sh = "noctalia msg brightness-down";
        };

      
      
      };
      _children = [
        {
          spawn-at-startup._args = [ "noctalia" ];
        }

        {
          window-rule._children = [
            { geometry-corner-radius = 20.0; }
            { clip-to-geometry = true; }
          ];
        }
      ];
    };
  };
}