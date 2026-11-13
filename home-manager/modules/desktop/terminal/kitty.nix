{ lib, pkgs, ... }:
let
  disabledWindowBindings = [
    "ctrl+shift+enter"
    "ctrl+shift+n"
    "ctrl+shift+w"
    "ctrl+shift+]"
    "ctrl+shift+["
    "ctrl+shift+f"
    "ctrl+shift+b"
    "ctrl+shift+`"
    "ctrl+shift+r"
    "ctrl+shift+1"
    "ctrl+shift+2"
    "ctrl+shift+3"
    "ctrl+shift+4"
    "ctrl+shift+5"
    "ctrl+shift+6"
    "ctrl+shift+7"
    "ctrl+shift+8"
    "ctrl+shift+9"
    "ctrl+shift+0"
    "ctrl+shift+f7"
    "ctrl+shift+f8"
    "ctrl+shift+right"
    "ctrl+tab"
    "ctrl+shift+left"
    "ctrl+shift+tab"
    "ctrl+shift+t"
    "ctrl+shift+q"
    "ctrl+shift+."
    "ctrl+shift+,"
    "ctrl+shift+alt+t"
  ];
in
{
  programs.kitty = {
    enable = true;

    # Colours, font and background_opacity come from Stylix
    # (stylix.opacity.terminal).
    settings = {
      confirm_os_window_close = 0;
      enable_audio_bell = true;
      mouse_hide_wait = "-1.0";
      dynamic_background_opacity = true;
      cursor_shape = "block";
      cursor_trail = 1;
      cursor_trail_decay = "0.1 0.4";
      cursor_trail_start_threshold = 2;

      # Kitty is only the terminal renderer. Tmux owns all persistent windows
      # and every Kitty process joins the same session.
      shell = "${pkgs.tmux}/bin/tmux new-session -A -s main";
      tab_bar_style = "hidden";
    };

    # Keep copy/paste, scrolling and font controls, but remove every default
    # binding that creates, closes, moves or selects a Kitty window or tab.
    keybindings = lib.genAttrs disabledWindowBindings (_: "no_op");
  };
}
