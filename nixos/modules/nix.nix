{ ... }:
{
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Weekly garbage collection. --delete-older-than 7d expires generations
  # rather than just unreachable paths, so system generations older than a
  # week stop appearing in the Limine boot menu. That is the trade for not
  # accumulating tens of GB; the current and recent generations stay.
  nix.gc = {
    automatic = true;
    dates = "weekly";
    persistent = true;
    options = "--delete-older-than 7d";
  };

  # Hardlink identical files in the store. Runs after GC, saves a few GB.
  nix.optimise = {
    automatic = true;
    dates = [ "weekly" ];
  };
}
