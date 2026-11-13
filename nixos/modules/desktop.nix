{ pkgs, ... }:
let
  sddmTheme = pkgs.catppuccin-sddm.override {
    flavor = "mocha";
    accent = "lavender";
    font = "Noto Sans";
  };
in
{
  services.xserver.enable = true;
  services.desktopManager.plasma6.enable = true;

  # SDDM has no Stylix target, so it is themed directly.
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    theme = "catppuccin-mocha-lavender";

    extraPackages = with pkgs.kdePackages; [
      qtsvg
      qtmultimedia
    ];
  };

  # The theme has to sit on the system path for SDDM to find it.
  environment.systemPackages = [ sddmTheme ];

  # Everything is installed declaratively, so the graphical package manager is
  # only a way to get out of sync. Plasma pulls it in because fwupd is enabled.
  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    discover
  ];

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };
}
