{ ... }:
{
  programs.plasma = {
    enable = true;

    # Colours, fonts, cursor, wallpaper and the global theme are owned by
    # Stylix (see nixos/modules/theme.nix). Setting workspace.lookAndFeel,
    # .colorScheme, .theme or .cursor here would clobber it: plasma-manager
    # writes those keys into ~/.config/kdeglobals, which takes priority over
    # the config directory Stylix installs them into.
    #
    # The icon theme is the exception - Stylix's KDE target never writes
    # [Icons] Theme - so it stays here, matching stylix.icons.dark.
    workspace.iconTheme = "Papirus-Dark";

    # Plasma's kded "gtkconfig" module rewrites ~/.gtkrc-2.0, ~/.config/gtkrc
    # and ~/.config/gtkrc-2.0 at every login, pointing GTK apps back at Breeze
    # and colliding with the GTK files home-manager manages - which fails the
    # whole activation at boot. Stylix tries to disable it, but only writes to
    # kded5rc; Plasma 6 reads kded6rc.
    configFile.kded6rc."Module-gtkconfig".autoload = {
      value = false;
      immutable = true;
    };

    # Make kitty the terminal Plasma opens: TerminalService is what Plasma 6
    # reads, TerminalApplication is the older key some apps still honour.
    configFile.kdeglobals.General = {
      TerminalApplication = "kitty";
      TerminalService = "kitty.desktop";
    };

    # Ctrl+Alt+T is Plasma's terminal shortcut, but konsole claims it in its
    # own desktop file (X-KDE-Shortcuts=Ctrl+Alt+T), so pointing the default
    # terminal at kitty is not enough - konsole's binding has to be cleared
    # and handed over explicitly. An empty list writes "none".
    shortcuts = {
      "services/org.kde.konsole.desktop"._launch = [ ];
      "services/kitty.desktop"._launch = "Ctrl+Alt+T";
    };

    panels = [
      {
        location = "bottom";
        alignment = "center";
        floating = true;
        height = 32;

        # Matches the current panel width on the 2560px display. Drop
        # lengthMode/minLength/maxLength for a full-width panel instead.
        lengthMode = "custom";
        minLength = 2256;
        maxLength = 2279;

        screen = 0;

        widgets = [
          "org.kde.plasma.kickoff"
          "org.kde.plasma.pager"
          {
            iconTasks.launchers = [
              # applications: rather than the /nix/store path Plasma recorded,
              # which breaks on every kitty update.
              "applications:kitty.desktop"
              "applications:systemsettings.desktop"
              "preferred://filemanager"
              "preferred://browser"
            ];
          }
          "org.kde.plasma.marginsseparator"
          "org.kde.plasma.systemtray"
          "org.kde.plasma.digitalclock"
          "org.kde.plasma.showdesktop"
        ];
      }
    ];
  };
}
