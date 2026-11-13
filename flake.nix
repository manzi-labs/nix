{
  description = "NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    # A second package set for software that has not reached 26.05. Used by
    # nixos/modules/overlays.nix to expose `pkgs.unstable`, and deliberately
    # not following nixpkgs - a `follows` here would defeat the point.
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    # Declarative Neovim. Release branches are named `nixos-YY.MM` and are
    # tested against the matching nixpkgs, so this tracks nixos-26.05 rather
    # than `main` (which requires nixpkgs-unstable). Upstream recommends not
    # overriding its nixpkgs input, but the branch already targets 26.05, so
    # following keeps the whole system on one nixpkgs. If evaluation ever
    # breaks on a missing vimPlugins attribute, drop the `follows` line.
    nixvim = {
      url = "github:nix-community/nixvim/nixos-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Global theming. Stylix has no home-manager input of its own; its nixos
    # module pulls in the home-manager module for every user automatically.
    stylix = {
      url = "github:nix-community/stylix/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      plasma-manager,
      stylix,
      nixvim,
      ...
    }@inputs:
    {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        specialArgs = { inherit inputs; };

        modules = [
          ./nixos/configuration.nix

          stylix.nixosModules.stylix

          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;

              # Move pre-existing unmanaged dotfiles aside instead of failing.
              backupFileExtension = "backup";

              extraSpecialArgs = { inherit inputs; };
              sharedModules = [
                plasma-manager.homeModules.plasma-manager
                nixvim.homeModules.nixvim
              ];

              users.manzi = ./home-manager/home.nix;
            };
          }
        ];
      };
    };
}
