{ pkgs, ... }:
{
  # The ArtCraft suite (github.com/storytold). All of it is 0.x, early-alpha,
  # clean-room reimplementation of Adobe and Office applications - treat it as
  # such. nixpkgs reviewed the provenance question explicitly in issue #571683
  # and closed it as resolved, which is why these are packaged upstream at all.
  home.packages = [
    # In nixpkgs, but only on unstable - 26.05 branched before any of them
    # landed, so these come through the `unstable` overlay and arrive as
    # Hydra-built binaries rather than local compiles. Move each one to plain
    # `pkgs.` at the next release bump.
    pkgs.unstable.photocraft # image editor, layered PSD/PSB
    pkgs.unstable.pdfcraft # PDF reader and editor
    pkgs.unstable.wordcraft # word processor
    pkgs.unstable.deckcraft # presentations
    pkgs.unstable.gridcraft # spreadsheets
    pkgs.unstable.vectorcraft # vector illustration

    # Not in nixpkgs yet, so wrapped from upstream AppImages locally. Each has
    # an open PR; delete the wrapper and move the app up to the list above as
    # its PR merges. See ../../../pkgs/artcraft.
    pkgs.artcraft.filmcraft # video editor
    pkgs.artcraft.figcraft # interface design
    pkgs.artcraft.texturecraft # 3D texture painting
    pkgs.artcraft.materialcraft # procedural materials
    pkgs.artcraft.craft-anything # inspect an app, rebuild it
  ];
}
