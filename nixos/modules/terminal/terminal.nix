{ pkgs, ... }:
{
  # Interactive terminal programs that home-manager configures (kitty, tmux,
  # neovim, lazygit) are installed per-user instead: Stylix only themes the
  # home-manager-managed copies.
  environment.systemPackages = with pkgs; [
    # Terminal features
    vim
    fastfetch
    wget
    curl
    zsh-powerlevel10k

    # Compilers and build systems
    gcc
    gnumake

    # Searching
    ripgrep
    fd
    fzf

    # Archive
    unzip
    gzip
    gnutar

    # Language and tooling. Editor tooling (language servers, formatters,
    # linters) is deliberately absent: nixvim wraps its own copies onto nvim's
    # PATH in home-manager/modules/development/editors, so a second system-wide
    # set would only drift from the one the editor actually uses.
    nodejs
    python3
    git

    # Kept on the interactive PATH on purpose: the documented workflow for this
    # flake is to run `nixfmt` by hand before finishing a change, so it has to
    # be a shell command and not just something inside nvim's wrapper.
    nixfmt

    # Clipboard
    wl-clipboard
    xclip
  ];

  programs.zsh.enable = true;

  # Powerlevel10k configuration
  environment.etc."powerlevel10k/p10k.zsh".source = ./p10k.zsh;

  # Default shell
  users.defaultUserShell = pkgs.zsh;

  environment.shells = with pkgs; [
    zsh
  ];
}
