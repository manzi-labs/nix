{ ... }:
{
  # Binary is `copilot`; config lives in ~/.copilot. Needs an active GitHub
  # Copilot subscription - authenticate with /login on first run.
  programs.github-copilot-cli.enable = true;

  programs.gh.enable = true;
}
