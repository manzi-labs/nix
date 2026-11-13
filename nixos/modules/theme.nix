{ pkgs, ... }:
let
  flavor = "mocha";
  accent = "lavender";
in
{
  # Single source of truth for the system palette. The Stylix NixOS module
  # re-exports all of this to every home-manager user
  # (stylix.homeManagerIntegration.followSystem, on by default), so nothing
  # below needs to be repeated in the home-manager config.
  stylix = {
    enable = true;
    polarity = "dark";

    base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-${flavor}.yaml";

    # Decorative only: the palette above is explicit, so no colours are
    # derived from this image. Swap the filename for any other wallpaper.
    image = ../../wallpapers/dark-waves.jpg;

    # All three must be set together, or none of them.
    # Posy's Improved Cursors are redrawn Windows cursors, so they keep the
    # Windows 11 shape and feel. Licensed CC-BY-NC-4.0, i.e. unfree in nixpkgs
    # terms - allowUnfree is already on. Posy_Cursor is the white set;
    # Posy_Cursor_Black is the dark one.
    cursor = {
      package = pkgs.posy-cursors;
      name = "Posy_Cursor";
      size = 24;
    };

    icons = {
      enable = true;
      package = pkgs.catppuccin-papirus-folders.override { inherit flavor accent; };
      dark = "Papirus-Dark";
      light = "Papirus-Light";
    };

    fonts = {
      monospace = {
        # Keep Meslo: the Powerlevel10k config relies on its glyphs.
        package = pkgs.meslo-lgs-nf;
        name = "MesloLGS NF";
      };

      sansSerif = {
        package = pkgs.noto-fonts;
        name = "Noto Sans";
      };

      serif = {
        package = pkgs.noto-fonts;
        name = "Noto Serif";
      };

      emoji = {
        package = pkgs.noto-fonts-color-emoji;
        name = "Noto Color Emoji";
      };

      sizes = {
        applications = 10;
        desktop = 10;
        popups = 10;
        terminal = 12;
      };
    };
  };
}
