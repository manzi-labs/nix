let
  flakePath = "/home/manzi/nix";
  flake = "${flakePath}#nixos";
in
{
  # System and home are one flake output, so there is no separate
  # `home-manager switch` - this rebuilds both.
  rebuild = "sudo nixos-rebuild switch --flake ${flake}";

  # Evaluate and build without activating. Run this before rebuild.
  check = "nixos-rebuild build --flake ${flake}";

  update = "nix flake update --flake ${flakePath} && sudo nixos-rebuild switch --flake ${flake}";

  # Boot into the previous generation's config without rebooting.
  rollback = "sudo nixos-rebuild switch --rollback";

  generations = "sudo nix-env --list-generations --profile /nix/var/nix/profiles/system";

  # Expire generations older than a week, system and user profiles both.
  gc = "sudo nix-collect-garbage --delete-older-than 7d && nix-collect-garbage --delete-older-than 7d";

  # Everything not currently referenced, including every old generation.
  # Wipes the Limine rollback entries, so keep it for when disk is tight.
  gc-all = "sudo nix-collect-garbage -d && nix-collect-garbage -d";

  # What is actually taking up space.
  gc-size = "nix path-info -Sh /run/current-system";

  v = "nvim";

  # Codex driving the local Ollama server instead of OpenAI.
  codex-local = "codex --oss --local-provider ollama -m gpt-oss:20b";

  webui = "xdg-open http://localhost:8080";
}
