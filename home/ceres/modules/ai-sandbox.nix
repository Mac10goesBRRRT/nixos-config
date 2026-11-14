{ pkgs, ... }:
let
  # The policy is pinned in the Nix store; changing it requires nh os switch.
  settings = ../assets/srt-settings.json;
  aiSandbox = pkgs.writeShellApplication {
    name = "ocbox";
    runtimeInputs = with pkgs; [
      bash
      bubblewrap
      coreutils
      findutils
      git
      opencode
      sandbox-runtime
    ];
    text = ''
      export AI_SANDBOX_SRT_SETTINGS=${settings}
      ${builtins.readFile ../scripts/ai-sandbox.sh}
    '';
  };
in
{
  home.packages = [
    pkgs.opencode
    pkgs.sandbox-runtime
    aiSandbox
  ];

  home.shellAliases.oc = "ocbox";
}
