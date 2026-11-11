{ ... }:
{
  home.shellAliases = {
    ls = "eza";
    ll = "eza -l --icons --git -h --time-style relative";
    llt = "eza -l --icons --git -T -h --time-style relative";
    cat = "bat";
    ssh = "kitten ssh";
  };
}