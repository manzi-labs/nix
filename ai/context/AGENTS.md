# This machine

NixOS 26.05, KDE Plasma 6 on Wayland, zsh + Powerlevel10k, kitty, neovim.
GPU: NVIDIA RTX 5070 Ti (16GB, Blackwell / compute 12.0), proprietary driver,
`hardware.nvidia.open = true`.

## Configuration lives in one flake

Everything - system and home - is in `~/nix`, built from a single output:

```
~/nix/
├── flake.nix                 nixosConfigurations.nixos (home-manager is a module of it)
├── ai/                       this folder: shared agent instructions + skills
├── nixos/
│   ├── configuration.nix     imports hardware-configuration.nix + modules/bundle.nix
│   └── modules/              bootloader, theme, desktop, ai, terminal/
└── home-manager/
    ├── home.nix, bundle.nix
    └── modules/{desktop,development,theme}/
```

There is **one** rebuild command - there is no separate `home-manager switch`:

```sh
sudo nixos-rebuild switch --flake ~/nix#nixos     # aliased to `rebuild`
```

Always `nixos-rebuild build --flake ~/nix#nixos` first; it evaluates and builds
without touching the running system. Roll back with
`sudo nixos-rebuild switch --rollback` or by picking an older generation in the
Limine boot menu.

## Conventions

- New system config goes in a module under `nixos/modules/` and is imported
  from `nixos/modules/bundle.nix`. Same pattern for `home-manager/bundle.nix`.
- Format with `nixfmt` before finishing.
- Theming is **Stylix only** (`nixos/modules/theme.nix`): Catppuccin Mocha with
  a lavender accent, defined once and inherited by home-manager. Never set
  colours, fonts or cursors in plasma-manager or per-app config - Stylix owns
  them. The icon theme is the one exception and lives in `plasma.nix`, because
  Stylix's KDE target does not write `[Icons] Theme`.
- plasma-manager owns panel layout and Plasma behaviour, nothing visual.
- Declaring `programs.plasma.panels` makes plasma-manager rebuild the panel
  from scratch and restart plasmashell on the next login, so widgets added by
  hand in the GUI are lost. Change the panel in Nix, not in Plasma.

## Working style

- Verify against the real system rather than assuming: `nix eval` the option,
  check the built store path, read the module source in nixpkgs/home-manager.
- Say plainly when something did not work. A command that printed "success"
  is not evidence the state actually changed.
