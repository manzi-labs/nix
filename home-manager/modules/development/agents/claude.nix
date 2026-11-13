{ ... }:

{
  programs.claude-code = {
    enable = true;

    settings = {
      model = "opus";

      permissions = {
        defaultMode = "default";
      };
    };
  };
}
