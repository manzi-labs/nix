{ pkgs, ... }:
{
  imports = [
    ./bundle.nix
  ];

  home = {
    username = "manzi";
    homeDirectory = "/home/manzi";
    stateVersion = "26.05";

    packages = with pkgs; [
      kdePackages.kate
      thunderbird
    ];
  };

  # Themed by Stylix (targets.lazygit).
  programs.lazygit.enable = true;
}
