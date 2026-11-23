{ ... }:
{
  home.shellAliases = {
    ll = "eza -al --icons --git -h --time-style relative --group-directories-first";
    ls = "eza -a --icons --git -h --time-style relative --group-directories-first";
    lt = "eza -l --icons --git -T -h --time-style relative --group-directories-first";
    cat = "bat";
    ssh = "kitten ssh";
    top = "btop";
  };

  #programs.bash.initExtra = ''
  #  PS1_FINAL='> '
  #  RPS1_FINAL=' <\D{%d.%m.%Y %H:%M:%S}'
  #  PROMPT_RULER_FINAL='\e[90m─\e[0m'
  #'';

  programs.starship = {
    enable = true;
  };
}
