# Shared AI folder

One source of truth for everything the coding agents on this machine share:
instructions, skills, and (later) MCP servers.

```
ai/
├── context/AGENTS.md     shared instructions - every agent reads this
└── skills/<name>/SKILL.md
```

## The contract

These files are symlinked **directly into the working tree**, not copied into
the nix store (`config.lib.file.mkOutOfStoreSymlink`, wired up in
`home-manager/modules/development/shared.nix`). So:

**Edit a file here and the next agent run picks it up. No rebuild.**

A `nixos-rebuild switch` is only needed when adding or removing a *link* -
that is, when a new agent is configured, not when content changes.

## Who reads what

| Agent | Instructions | Skills |
| --- | --- | --- |
| Claude Code | `~/.claude/CLAUDE.md` | `~/.claude/skills` |
| Codex | `~/.codex/AGENTS.md` | `~/.codex/skills` |
| Copilot CLI | `~/.copilot/copilot-instructions.md` | `~/.copilot/skills` |
| opencode | `~/.config/opencode/AGENTS.md` | `~/.config/opencode/skills` |

All eight paths point back here.

## Adding a skill

Create `skills/<name>/SKILL.md` with YAML frontmatter containing `name` and a
`description` written so an agent can tell from it alone whether the skill
applies. Supporting files can sit alongside `SKILL.md` in the same folder.
