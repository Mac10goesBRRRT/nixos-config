{ pkgs, inputs, lib, ... }:
let
  flyline = inputs.flyline.packages.${pkgs.stdenv.hostPlatform.system}.flyline;
in
{
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  system.stateVersion = "25.11";

  environment.shellAliases = {
    ll = "eza -al --icons --git -h --time-style relative --group-directories-first";
    ls = "eza -a --icons --git -h --time-style relative --group-directories-first";
    cat = "bat";
    top = "btop";
  };
  environment.systemPackages = with pkgs; [
    eza
    bat
    btop
  ];

  virtualisation.podman = {
    enable = true;
  };

  #programs.bash.promptInit = ''
  #  if (( EUID == 0 )); then
  #    PS1='\[\e[01;31m\]\u@\h\[\e[00m\]:\[\e[01;34m\]\w\[\e[00m\]\n\$ '
  #  else
  #    PS1='\[\e[01;32m\]\u@\h\[\e[00m\]:\[\e[01;34m\]\w\[\e[00m\]\n\$ '
  #  fi
  #'';

  #programs.bash.interactiveShellInit = lib.mkAfter ''
  #  if (( EUID == 0 )); then
  #    PS1_FINAL='# '
  #    RPS1_FINAL=' <\D{%d.%m.%Y %H:%M:%S}'
  #    PROMPT_RULER_FINAL='\e[90m─\e[0m'
  #    if enable -f ${flyline}/lib/libflyline.so flyline; then
  #      flyline mouse --mode disabled
  #    fi
  #  fi
  #'';
}
