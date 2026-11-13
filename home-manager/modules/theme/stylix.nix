{ lib, ... }:
{
  # Home-manager-side Stylix adjustments. The palette itself is defined once in
  # nixos/modules/theme.nix and inherited from there.

  stylix.targets = {
    # Inside a Plasma session Qt applications are themed through the KDE
    # platform theme (stylix.targets.kde), and Stylix's own Qt target only
    # supports the qtct platform - leaving it on just emits a warning.
    qt.enable = false;

    # Nothing GNOME here; the target only contributes a useless autostart entry.
    gnome.enable = false;
  };

  # Stylix's KDE target adds an autostart entry that runs
  # `plasma-apply-lookandfeel --apply stylix` and `plasma-apply-wallpaperimage`
  # on *every* login, which restarts plasmashell and leaves the panel and
  # wallpaper missing for ~20s each time. The theme is already persisted in
  # ~/.config/kdeglobals, and home-manager re-applies it on every
  # nixos-rebuild switch, so the login-time pass is redundant.
  #
  # This clears Stylix's entries only: plasma-manager installs its own
  # autostart entry through xdg.configFile, which is untouched.
  xdg.autostart.entries = lib.mkForce [ ];
}
