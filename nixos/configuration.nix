# System-wide configuration. Anything that is not a one-off lives in
# ./modules; see ./modules/bundle.nix for the full list.
#
# Rebuild with: sudo nixos-rebuild switch --flake ~/nix#nixos

{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./modules/bundle.nix
  ];

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/London";

  i18n.defaultLocale = "en_GB.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_GB.UTF-8";
    LC_IDENTIFICATION = "en_GB.UTF-8";
    LC_MEASUREMENT = "en_GB.UTF-8";
    LC_MONETARY = "en_GB.UTF-8";
    LC_NAME = "en_GB.UTF-8";
    LC_NUMERIC = "en_GB.UTF-8";
    LC_PAPER = "en_GB.UTF-8";
    LC_TELEPHONE = "en_GB.UTF-8";
    LC_TIME = "en_GB.UTF-8";
  };

  services.printing.enable = true;

  # Sound.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  users.users."manzi" = {
    isNormalUser = true;
    description = "Isaac Manzi";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
  };

  programs.firefox.enable = true;

  nixpkgs.config.allowUnfree = true;

  # Nvidia.
  hardware.graphics.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;

    powerManagement = {
      enable = true;
      kernelSuspendNotifier = false;
      finegrained = false;
    };

    open = true;
    nvidiaSettings = true;
  };

  environment.systemPackages = with pkgs; [
    # Core
    home-manager
  ];

  # This value determines the NixOS release from which the default settings for
  # stateful data were taken. Do not change it after the initial install.
  system.stateVersion = "26.05";
}
