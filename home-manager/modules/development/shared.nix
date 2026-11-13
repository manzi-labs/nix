{ config, ... }:
let
  aiDir = "${config.home.homeDirectory}/nix/ai";
  link = config.lib.file.mkOutOfStoreSymlink;
in
{
  # These point straight at the working tree rather than at a nix store copy,
  # so editing a SKILL.md or AGENTS.md takes effect on the next agent run with
  # no rebuild. That is why the modules' own `skills` and `context` options are
  # left unset: both would copy the content into the store. Each module guards
  # those writes behind `mkIf`, so with the defaults nothing here collides.
  home.file = {
    ".claude/skills".source = link "${aiDir}/skills";
    ".claude/CLAUDE.md".source = link "${aiDir}/context/AGENTS.md";

    ".codex/skills".source = link "${aiDir}/skills";
    ".codex/AGENTS.md".source = link "${aiDir}/context/AGENTS.md";

    ".copilot/skills".source = link "${aiDir}/skills";
    ".copilot/copilot-instructions.md".source = link "${aiDir}/context/AGENTS.md";
  };

  xdg.configFile = {
    "opencode/skills".source = link "${aiDir}/skills";
    "opencode/AGENTS.md".source = link "${aiDir}/context/AGENTS.md";
  };

  # One MCP server set shared by every agent through their enableMcpIntegration
  # option. Empty for now; this is where servers get added.
  programs.mcp = {
    enable = true;
    servers = { };
  };
}
