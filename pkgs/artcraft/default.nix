# The ArtCraft apps that nixpkgs does not package yet, wrapped from upstream's
# own AppImages. See ./mk-appimage.nix for how, and why this is temporary.
#
# The other six (photocraft, pdfcraft, wordcraft, deckcraft, gridcraft,
# vectorcraft) are in nixos-unstable and come from the `unstable` overlay
# instead - see home-manager/modules/desktop/artcraft.nix.
#
# Bumping one: change version, blank the hash, and run
#   nix store prefetch-file --json <the url from mk-appimage.nix>
{ callPackage }:
let
  mkCraftAppImage = callPackage ./mk-appimage.nix { };
in
{
  filmcraft = mkCraftAppImage {
    pname = "filmcraft";
    version = "0.20.1";
    hash = "sha256-SiWuyy6UgbZec1NSi8qeSoxTiN1V8Uhv/mRQLgi9+gI=";
    description = "Native non-linear video editor";
  };

  figcraft = mkCraftAppImage {
    pname = "figcraft";
    version = "0.18.1";
    hash = "sha256-lYaULdYxuWtMVSKYjp6AITkHuAIv+vvKYko/wRrnqek=";
    description = "Native interface design tool";
  };

  texturecraft = mkCraftAppImage {
    pname = "texturecraft";
    version = "0.6.1";
    hash = "sha256-kEdgAW/TdL8J/RtKPIQBy8fmvDy8DUQn43S5v4ExbKY=";
    description = "3D texture painting tool";
  };

  materialcraft = mkCraftAppImage {
    pname = "materialcraft";
    version = "0.4.1";
    hash = "sha256-1R++QDSoIgR0UHIi9k2AHiZknIEzs+e0WPPpdYwItqE=";
    description = "Node-based procedural material designer";
  };

  craft-anything = mkCraftAppImage {
    pname = "craft-anything";
    version = "0.6.1";
    hash = "sha256-fq3eHXSrQsyDiGL+P4MePPPJ+mul4r8E4oJLvEcUYTQ=";
    description = "Software explorer that inspects an app or site and rebuilds it";
  };
}
