{ lib, ... }:
let
  windowBindings = lib.concatMapStringsSep "\n" (
    number: "bind-key -n M-${toString number} select-window -t :${toString number}"
  ) (lib.range 1 9);
in
{
  programs.tmux = {
    enable = true;
    mouse = true;
    clock24 = true;
    keyMode = "vi";
    terminal = "screen-256color";
    historyLimit = 10000;
    baseIndex = 1;
    escapeTime = 0;

    extraConfig = ''
      set -g pane-base-index 1
      set -g renumber-windows on

      bind-key -n M-t new-window -c "#{pane_current_path}"
      ${windowBindings}
    '';
  };
}
