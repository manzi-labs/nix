{ ... }:
{
  imports = [
    ./bootloader.nix
    ./nix.nix
    ./overlays.nix
    ./theme.nix
    ./desktop.nix
    ./ai.nix
    ./terminal/terminal.nix
  ];
}
