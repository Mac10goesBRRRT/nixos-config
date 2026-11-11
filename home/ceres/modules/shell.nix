{ ... }:
{
  home.shellAliases = {
    ll = "eza -al --icons --git -h --time-style relative --group-directories-first";
    ls = "eza -a --icons --git -h --time-style relative --group-directories-first";
    lt = "eza -l --icons --git -T -h --time-style relative --group-directories-first";
    cat = "bat";
    ssh = "kitten ssh";
  };
}