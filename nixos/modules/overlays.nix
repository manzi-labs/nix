{ inputs, ... }:
{
  # home-manager runs with `useGlobalPkgs = true`, so it is handed this same
  # package set - one overlay here serves both the system and home.
  nixpkgs.overlays = [
    (final: prev: {
      # A second package set, only for things that have not reached 26.05.
      # Reach for `pkgs.unstable.foo` deliberately and sparingly: each package
      # taken from here drags in its own build of the unstable closure, and
      # none of it gets the testing the release branch has had.
      unstable = import inputs.nixpkgs-unstable {
        # Not `prev.system`, which is deprecated in favour of this.
        inherit (prev.stdenv.hostPlatform) system;
        config.allowUnfree = true;
      };

      # Local derivations. Currently the five ArtCraft apps that are not in
      # nixpkgs at all; see ../../pkgs/artcraft.
      artcraft = final.callPackage ../../pkgs/artcraft { };
    })
  ];
}
