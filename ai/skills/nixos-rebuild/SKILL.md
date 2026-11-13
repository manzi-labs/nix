---
name: nixos-rebuild
description: Build, switch, inspect or roll back this machine's NixOS flake at ~/nix. Use whenever a change to any .nix file needs to take effect, when a rebuild fails, or when checking what a Nix option actually evaluates to.
---

# Rebuilding this machine

System and home are one flake output, so a single command applies both.

## Always build before switching

```sh
nixos-rebuild build --flake ~/nix#nixos
```

Evaluates and builds everything without activating. Catches option conflicts
and type errors with no risk to the running system. Only then:

```sh
sudo nixos-rebuild switch --flake ~/nix#nixos
```

`sudo` needs a real terminal here - it cannot read a password otherwise. If you
are an agent without a TTY, ask the user to run the switch themselves.

## Checking what an option evaluates to

Faster and more reliable than reading the Nix source and guessing:

```sh
nix eval ~/nix#nixosConfigurations.nixos.config.<option.path>
nix eval --raw ~/nix#nixosConfigurations.nixos.config.stylix.cursor.name
nix eval --json ~/nix#nixosConfigurations.nixos.config.home-manager.users.manzi.xdg.autostart.entries
```

Home Manager options live under
`nixosConfigurations.nixos.config.home-manager.users.manzi.*`.

To check whether a package is cached rather than built locally:

```sh
h=$(basename "$(nix eval --raw ~/nix#nixosConfigurations.nixos.config.<pkg>.outPath)" | cut -d- -f1)
curl -s -o /dev/null -w "%{http_code}\n" "https://cache.nixos.org/$h.narinfo"   # 200 = cached
```

## Common failures

**"Existing file ... would be clobbered by backing up ..."** - Home Manager
wants to manage a file that already exists *and* a `.backup` from an earlier
switch is in the way. Look at the file first, then remove the unwanted copy.
Check what regenerated it: Plasma's kded modules rewrite config files at login
and will fight Home Manager every boot until the responsible module is disabled
in `kded6rc`.

**"has conflicting definition values"** - two modules set the same option.
Stylix sets a lot implicitly, so it is usually Stylix versus a hand-written
value. Prefer deleting the hand-written one; use `lib.mkForce` only when
Stylix's value is genuinely wrong.

**Activation partly applied** - the system generation can switch while
`home-manager-manzi.service` fails. Never assume a switch fully worked:

```sh
systemctl status home-manager-manzi.service
journalctl -u home-manager-manzi.service -n 40
```

## Rolling back

Pick a previous generation in the Limine boot menu, or:

```sh
sudo nixos-rebuild switch --rollback
```
