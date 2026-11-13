{ ... }:

{
  programs.codex = {
    enable = true;

    settings = {
      model = "gpt-5.1-codex";

      approval_policy = "on-request";
      sandbox_mode = "workspace-write";
    };
  };
}
