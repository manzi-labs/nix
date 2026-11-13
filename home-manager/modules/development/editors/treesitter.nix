{ ... }:
{
  # Syntax, indentation and text objects.
  #
  # `grammarPackages` is deliberately left at its default, which is
  # `plugins.treesitter.package.allGrammars`: every grammar is compiled by Nix
  # and lives in the store. nvim-treesitter's own `:TSInstall` path - which
  # clones a grammar repo and runs a C compiler at runtime - is never used, so
  # there is nothing to break on a fresh machine and nothing to keep in sync.
  # If the closure size ever becomes a problem, replace the default with an
  # explicit list of `pkgs.vimPlugins.nvim-treesitter.builtGrammars.<lang>`.
  programs.nixvim.plugins = {
    treesitter = {
      enable = true;

      settings = {
        highlight.enable = true;
        indent.enable = true;
      };

      folding.enable = false;
    };

    # Sticky header showing the enclosing function/class.
    treesitter-context = {
      enable = true;
      settings = {
        max_lines = 3;
        trim_scope = "outer";
      };
    };

    # Structural select/move/swap on treesitter nodes.
    treesitter-textobjects = {
      enable = true;
      settings = {
        select = {
          enable = true;
          lookahead = true;
          keymaps = {
            "af" = "@function.outer";
            "if" = "@function.inner";
            "ac" = "@class.outer";
            "ic" = "@class.inner";
            "aa" = "@parameter.outer";
            "ia" = "@parameter.inner";
          };
        };
        move = {
          enable = true;
          set_jumps = true;
          goto_next_start = {
            "]f" = "@function.outer";
            "]c" = "@class.outer";
          };
          goto_previous_start = {
            "[f" = "@function.outer";
            "[c" = "@class.outer";
          };
        };
      };
    };
  };
}
