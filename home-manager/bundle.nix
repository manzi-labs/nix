{ ... }:
{
  imports = [
    ./modules/theme/stylix.nix

    ./modules/desktop/artcraft.nix
    ./modules/desktop/plasma/plasma.nix
    ./modules/desktop/terminal/kitty.nix
    ./modules/desktop/terminal/zsh.nix
    ./modules/desktop/terminal/bash.nix
    ./modules/desktop/terminal/tmux.nix

    ./modules/development/editors/nixvim.nix

    ./modules/development/ides.nix
    ./modules/development/keybindings.nix

    ./modules/development/shared.nix
    ./modules/development/agents/claude.nix
    ./modules/development/agents/codex.nix
    ./modules/development/agents/copilot.nix
    ./modules/development/agents/opencode.nix
  ];
}
