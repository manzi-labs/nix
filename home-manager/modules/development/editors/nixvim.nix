{ pkgs, ... }:
{
  # Neovim, defined entirely in Nix. There is no Mason, no lazy.nvim and no
  # runtime plugin or language-server download anywhere in this config: every
  # plugin, grammar, LSP, formatter and linter is a nixpkgs derivation baked
  # onto the wrapped `nvim`'s PATH, so the editor is identical on any machine
  # that builds this flake.
  #
  # Colours are deliberately absent. Stylix's nixvim target assigns the
  # Catppuccin Mocha palette to `programs.nixvim` by itself (through
  # mini.base16), exactly like every other themed app here.
  imports = [
    ./ui.nix
    ./treesitter.nix
    ./lsp.nix
    ./completion.nix
    ./copilot.nix
    ./format.nix
  ];

  programs.nixvim = {
    enable = true;
    defaultEditor = true;

    # Reuse the nixpkgs instance the rest of the system already evaluated.
    # Without this, nixvim imports `nixpkgs.source` itself and builds a second
    # package set - which both doubles evaluation work and drops this system's
    # nixpkgs config (notably allowUnfree). It is also what silences nixvim's
    # warning about `inputs.nixvim.inputs.nixpkgs.follows`, since the warning
    # only fires when nixvim constructs `pkgs` on its own.
    nixpkgs.pkgs = pkgs;

    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    # Copilot and the npm-packaged servers (typescript, tailwind, yaml, ...)
    # need node. Wiring it here keeps it on nvim's PATH without installing it
    # into the interactive shell profile.
    withNodeJs = true;
    withRuby = false;

    # Wayland: the unnamed register goes through wl-clipboard.
    clipboard = {
      register = "unnamedplus";
      providers.wl-copy.enable = true;
    };

    # Byte-compile the generated config and use the bytecode module loader.
    luaLoader.enable = true;
    performance.byteCompileLua.enable = true;

    globals = {
      mapleader = " ";
      maplocalleader = " ";
    };

    opts = {
      # Line numbers and gutter
      number = true;
      relativenumber = true;
      numberwidth = 2;
      signcolumn = "yes";
      cursorline = true;
      colorcolumn = "100";

      # Indentation: two spaces, which is what the web stack and this flake use.
      expandtab = true;
      shiftwidth = 2;
      tabstop = 2;
      softtabstop = 2;
      smartindent = true;
      breakindent = true;

      # Searching
      ignorecase = true;
      smartcase = true;
      incsearch = true;
      hlsearch = true;

      # Splits open where you expect them to
      splitright = true;
      splitbelow = true;

      # Persistent undo instead of swap files
      undofile = true;
      swapfile = false;
      backup = false;

      # Responsiveness
      updatetime = 250;
      timeoutlen = 400;
      scrolloff = 8;
      sidescrolloff = 8;

      termguicolors = true;
      mouse = "a";
      showmode = false; # lualine already shows the mode
      laststatus = 3; # one global statusline
      cmdheight = 1;
      pumheight = 12;
      conceallevel = 0;
    };

    diagnostic.settings = {
      virtual_text = {
        prefix = "●";
        spacing = 2;
      };
      signs = true;
      underline = true;
      update_in_insert = false;
      severity_sort = true;
      float = {
        border = "rounded";
        source = true;
      };
    };

    keymaps = [
      # --- general ---
      {
        mode = "n";
        key = "<Esc>";
        action = "<cmd>nohlsearch<CR>";
        options.desc = "Clear search highlight";
      }
      {
        mode = "n";
        key = "<leader>w";
        action = "<cmd>write<CR>";
        options.desc = "Write file";
      }
      {
        mode = "n";
        key = "<leader>q";
        action = "<cmd>confirm quit<CR>";
        options.desc = "Quit";
      }

      # --- window navigation ---
      {
        mode = "n";
        key = "<C-h>";
        action = "<C-w>h";
        options.desc = "Window left";
      }
      {
        mode = "n";
        key = "<C-j>";
        action = "<C-w>j";
        options.desc = "Window down";
      }
      {
        mode = "n";
        key = "<C-k>";
        action = "<C-w>k";
        options.desc = "Window up";
      }
      {
        mode = "n";
        key = "<C-l>";
        action = "<C-w>l";
        options.desc = "Window right";
      }

      # --- buffers (bufferline) ---
      {
        mode = "n";
        key = "<Tab>";
        action = "<cmd>BufferLineCycleNext<CR>";
        options.desc = "Next buffer";
      }
      {
        mode = "n";
        key = "<S-Tab>";
        action = "<cmd>BufferLineCyclePrev<CR>";
        options.desc = "Previous buffer";
      }
      {
        mode = "n";
        key = "<leader>x";
        action = "<cmd>bdelete<CR>";
        options.desc = "Close buffer";
      }

      # --- file tree ---
      {
        mode = "n";
        key = "<C-n>";
        action = "<cmd>NvimTreeToggle<CR>";
        options.desc = "Toggle file tree";
      }
      {
        mode = "n";
        key = "<leader>e";
        action = "<cmd>NvimTreeFocus<CR>";
        options.desc = "Focus file tree";
      }

      # --- diagnostics ---
      {
        mode = "n";
        key = "<leader>tt";
        action = "<cmd>Trouble diagnostics toggle<CR>";
        options.desc = "Toggle diagnostics list";
      }
      {
        mode = "n";
        key = "<leader>td";
        action = "<cmd>Trouble diagnostics toggle filter.buf=0<CR>";
        options.desc = "Buffer diagnostics";
      }

      # --- terminal ---
      {
        mode = [
          "n"
          "t"
        ];
        key = "<A-i>";
        action = "<cmd>ToggleTerm direction=float<CR>";
        options.desc = "Toggle floating terminal";
      }
      {
        mode = "t";
        key = "<Esc><Esc>";
        action = "<C-\\><C-n>";
        options.desc = "Leave terminal mode";
      }

      # --- move the visual selection ---
      {
        mode = "v";
        key = "J";
        action = ":m '>+1<CR>gv=gv";
        options.desc = "Move selection down";
      }
      {
        mode = "v";
        key = "K";
        action = ":m '<-2<CR>gv=gv";
        options.desc = "Move selection up";
      }

      # Keep the cursor centred when half-paging.
      {
        mode = "n";
        key = "<C-d>";
        action = "<C-d>zz";
      }
      {
        mode = "n";
        key = "<C-u>";
        action = "<C-u>zz";
      }
    ];

    # Tools nvim itself shells out to: telescope needs ripgrep and fd,
    # gitsigns needs git.
    extraPackages = with pkgs; [
      git
      ripgrep
      fd
      fzf
    ];
  };
}
