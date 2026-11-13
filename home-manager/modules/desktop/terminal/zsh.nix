{ pkgs, lib, ... }:

let
  aliases = import ./aliases.nix;
in
{
  programs.zsh = {
    enable = true;
    enableCompletion = true;

    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    history.size = 10000;
    shellAliases = aliases;

    setOptions = [
      "AUTO_CD"
    ];

    oh-my-zsh = {
      enable = true;
      theme = "";

      plugins = [
        "git"
        "gh"
        "dirhistory"
        "history"
      ];
    };

    # Load Powerlevel10k after Oh My Zsh
    initContent = lib.mkAfter ''
      # Show system information whenever tmux starts a new interactive shell.
      if [[ -n "$TMUX" ]]; then
        ${pkgs.fastfetch}/bin/fastfetch
      fi

      # Load Powerlevel10k theme
      source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme

      # Load custom Powerlevel10k configuration
      source /etc/powerlevel10k/p10k.zsh
    '';
  };
}
