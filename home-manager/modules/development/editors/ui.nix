{ ... }:
{
  # The parts that make nvim look and move like an IDE: file tree, tabline,
  # statusline, fuzzy finder, git gutter, breadcrumbs, dashboard. This is the
  # NvChad plugin set, except every plugin is a nixpkgs derivation rather than
  # something a plugin manager fetches at runtime.
  #
  # No `theme`/colour options are set anywhere below - Stylix owns those, and
  # lualine/bufferline both derive their colours from the active colourscheme.
  programs.nixvim.plugins = {

    # --- icons, needed by most of the UI plugins ---
    web-devicons.enable = true;

    # --- file tree ---
    nvim-tree = {
      enable = true;
      settings = {
        hijack_cursor = true;
        sync_root_with_cwd = true;
        view = {
          width = 32;
          side = "left";
          preserve_window_proportions = true;
        };
        renderer = {
          highlight_git = true;
          indent_markers.enable = true;
          icons.show = {
            file = true;
            folder = true;
            folder_arrow = true;
            git = true;
          };
        };
        git.enable = true;
        diagnostics.enable = true;
        filters.dotfiles = false;
        actions.open_file.quit_on_open = false;
      };
    };

    # --- tabline (NvChad's "tabufline") ---
    bufferline = {
      enable = true;
      settings.options = {
        mode = "buffers";
        diagnostics = "nvim_lsp";
        always_show_bufferline = true;
        show_buffer_close_icons = true;
        separator_style = "thin";
        offsets = [
          {
            filetype = "NvimTree";
            text = "Files";
            highlight = "Directory";
            separator = true;
          }
        ];
      };
    };

    # --- statusline ---
    lualine = {
      enable = true;
      settings = {
        options = {
          globalstatus = true;
          component_separators = {
            left = "";
            right = "";
          };
          section_separators = {
            left = "";
            right = "";
          };
        };
        sections = {
          lualine_a = [ "mode" ];
          lualine_b = [
            "branch"
            "diff"
          ];
          lualine_c = [
            {
              __unkeyed-1 = "filename";
              path = 1;
            }
          ];
          lualine_x = [
            "diagnostics"
            "filetype"
          ];
          lualine_y = [ "progress" ];
          lualine_z = [ "location" ];
        };
      };
    };

    # --- breadcrumbs / winbar ---
    navic = {
      enable = true;
      settings.highlight = true;
    };
    barbecue = {
      enable = true;
      settings.show_dirname = false;
    };

    # --- fuzzy finder ---
    telescope = {
      enable = true;

      extensions = {
        # Native C sorter: this is why fzf is in extraPackages.
        fzf-native = {
          enable = true;
          settings = {
            fuzzy = true;
            case_mode = "smart_case";
          };
        };
        # Route vim.ui.select through telescope (code actions, etc).
        ui-select.enable = true;
      };

      settings.defaults = {
        prompt_prefix = "   ";
        selection_caret = " ";
        sorting_strategy = "ascending";
        layout_config = {
          prompt_position = "top";
          horizontal.preview_width = 0.55;
        };
      };

      keymaps = {
        "<leader>ff" = {
          action = "find_files";
          options.desc = "Find files";
        };
        "<leader>fa" = {
          action = "find_files hidden=true no_ignore=true";
          options.desc = "Find all files";
        };
        "<leader>fw" = {
          action = "live_grep";
          options.desc = "Live grep";
        };
        "<leader>fb" = {
          action = "buffers";
          options.desc = "Find buffers";
        };
        "<leader>fh" = {
          action = "help_tags";
          options.desc = "Help tags";
        };
        "<leader>fo" = {
          action = "oldfiles";
          options.desc = "Recent files";
        };
        "<leader>fz" = {
          action = "current_buffer_fuzzy_find";
          options.desc = "Find in buffer";
        };
        "<leader>fd" = {
          action = "diagnostics";
          options.desc = "Diagnostics";
        };
        "<leader>gc" = {
          action = "git_commits";
          options.desc = "Git commits";
        };
        "<leader>gs" = {
          action = "git_status";
          options.desc = "Git status";
        };
      };
    };

    # project.nvim is deliberately NOT enabled. It spams
    # "project.util.history.write_history: No data available to write!" on every
    # write when its history file is empty, and telescope's find_files plus
    # nvim-tree's `sync_root_with_cwd` already cover root detection.
    # project-nvim.enable = true;

    # --- keybinding discoverability ---
    which-key = {
      enable = true;
      settings = {
        delay = 300;
        spec = [
          {
            __unkeyed-1 = "<leader>f";
            group = "Find";
          }
          {
            __unkeyed-1 = "<leader>g";
            group = "Git";
          }
          {
            __unkeyed-1 = "<leader>l";
            group = "LSP";
          }
          {
            __unkeyed-1 = "<leader>t";
            group = "Toggle";
          }
        ];
      };
    };

    # --- git ---
    gitsigns = {
      enable = true;
      settings = {
        current_line_blame = false;
        signcolumn = true;
        numhl = false;
      };
    };
    lazygit.enable = true;

    # --- editing quality of life ---
    comment.enable = true;
    nvim-autopairs.enable = true;
    nvim-surround.enable = true;
    todo-comments.enable = true;

    indent-blankline = {
      enable = true;
      settings = {
        indent.char = "│";
        scope.enabled = true;
      };
    };

    # Inline colour swatches for hex/rgb values - handy across the web stack.
    colorizer = {
      enable = true;
      settings.user_default_options = {
        css = true;
        tailwind = true;
        names = false;
      };
    };

    # --- startup screen ---
    alpha = {
      enable = true;
      theme = "dashboard";
    };

    # --- diagnostics list ---
    trouble.enable = true;

    # --- LSP progress spinner ---
    fidget.enable = true;

    # --- nicer cmdline / messages / popups ---
    notify = {
      enable = true;
      settings = {
        render = "compact";
        stages = "fade";
        timeout = 2500;
      };
    };
    noice = {
      enable = true;
      settings = {
        lsp.override = {
          "vim.lsp.util.convert_input_to_markdown_lines" = true;
          "vim.lsp.util.stylize_markdown" = true;
          "cmp.entry.get_documentation" = true;
        };
        presets = {
          bottom_search = true;
          command_palette = true;
          long_message_to_split = true;
          inc_rename = false;
          lsp_doc_border = true;
        };
      };
    };

    # --- integrated terminal ---
    toggleterm = {
      enable = true;
      settings = {
        direction = "float";
        float_opts.border = "rounded";
        size = 15;
      };
    };
  };
}
