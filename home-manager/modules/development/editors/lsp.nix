{ pkgs, ... }:
{
  # Language servers.
  #
  # Two things to know about the API being used here, because the older one is
  # still all over the internet:
  #
  #   * `plugins.lspconfig` only *installs* nvim-lspconfig, which is where the
  #     upstream default `cmd`, `filetypes` and `root_markers` for each server
  #     come from. It enables nothing by itself.
  #   * servers are then declared under the top-level `lsp.servers.<name>`,
  #     which maps onto neovim's native `vim.lsp.config()`/`vim.lsp.enable()`.
  #     Per-server options live in `.config` and use neovim's own snake_case
  #     keys. (`.config` was briefly called `.settings`; that name still
  #     evaluates but emits a rename warning.)
  #
  # The legacy `plugins.lsp` module is not used - its own source says it "will
  # be dropped entirely in a few months".
  #
  # Every `lsp.servers.<name>.package` defaults to the right nixpkgs
  # derivation and is added to nvim's PATH automatically, which is what
  # replaces Mason.
  programs.nixvim = {
    plugins = {
      lspconfig.enable = true;

      # Feeds the SchemaStore catalogue to jsonls and yamlls, so package.json,
      # tsconfig.json, GitHub workflows etc. validate and complete.
      schemastore = {
        enable = true;
        json.enable = true;
        yaml.enable = true;
      };

      # Java is special: nvim-jdtls drives jdtls through its own client, and
      # this module registers `lsp.servers.jdtls` itself - so jdtls must not
      # also be declared below.
      jdtls.enable = true;

      # Dart/Flutter is likewise special: flutter-tools manages the dart
      # language server (plus device/emulator commands), so `lsp.servers.dartls`
      # is intentionally left off to avoid two clients attaching to one buffer.
      flutter-tools.enable = true;
    };

    lsp = {
      inlayHints.enable = true;

      keymaps = [
        {
          key = "gd";
          lspBufAction = "definition";
          options.desc = "Go to definition";
        }
        {
          key = "gD";
          lspBufAction = "declaration";
          options.desc = "Go to declaration";
        }
        {
          key = "gr";
          lspBufAction = "references";
          options.desc = "References";
        }
        {
          key = "gi";
          lspBufAction = "implementation";
          options.desc = "Implementation";
        }
        {
          key = "gt";
          lspBufAction = "type_definition";
          options.desc = "Type definition";
        }
        {
          key = "K";
          lspBufAction = "hover";
          options.desc = "Hover docs";
        }
        {
          mode = "i";
          key = "<C-k>";
          lspBufAction = "signature_help";
          options.desc = "Signature help";
        }
        {
          key = "<leader>lr";
          lspBufAction = "rename";
          options.desc = "Rename symbol";
        }
        {
          key = "<leader>la";
          lspBufAction = "code_action";
          options.desc = "Code action";
        }
        {
          key = "<leader>ls";
          lspBufAction = "document_symbol";
          options.desc = "Document symbols";
        }
        {
          key = "<leader>ld";
          action = "<cmd>lua vim.diagnostic.open_float()<CR>";
          options.desc = "Line diagnostics";
        }
        {
          key = "]d";
          action = "<cmd>lua vim.diagnostic.jump({ count = 1, float = true })<CR>";
          options.desc = "Next diagnostic";
        }
        {
          key = "[d";
          action = "<cmd>lua vim.diagnostic.jump({ count = -1, float = true })<CR>";
          options.desc = "Previous diagnostic";
        }
      ];

      servers = {
        # ---------- web ----------
        ts_ls.enable = true; # TypeScript / JavaScript / JSX / TSX
        eslint.enable = true;
        html.enable = true;
        cssls.enable = true;
        tailwindcss.enable = true;
        emmet_language_server.enable = true;
        svelte.enable = true;
        vue_ls.enable = true;
        astro.enable = true;
        graphql.enable = true;

        # jsonls/yamlls get their schemas from plugins.schemastore above.
        jsonls.enable = true;
        yamlls.enable = true;

        # ---------- C / C++ / Qt ----------
        # clangd reads compile_commands.json; generate it with
        # `cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON` or Qt Creator.
        clangd = {
          enable = true;
          config.cmd = [
            "clangd"
            "--background-index"
            "--clang-tidy"
            "--header-insertion=iwyu"
            "--completion-style=detailed"
            "--offset-encoding=utf-16"
          ];
        };

        # CMake: neocmakelsp is the maintained one (the python `cmake` server
        # is also packaged, as `lsp.servers.cmake`).
        neocmake.enable = true;

        # QML. The binary ships inside kdePackages.qtdeclarative, which nixvim
        # already knows about. If it cannot resolve your imports, append
        # "-I" + the module path to `config.cmd` rather than patching Lua.
        qmlls.enable = true;

        # ---------- SQL ----------
        sqls.enable = true;

        # ---------- nix ----------
        # nixd is given this flake's own option set, so it completes and
        # documents NixOS and home-manager options, not just language builtins.
        nixd = {
          enable = true;
          config.settings.nixd = {
            nixpkgs.expr = "import <nixpkgs> { }";
            formatting.command = [ "nixfmt" ];
            options = {
              nixos.expr = ''(builtins.getFlake "/home/manzi/nix").nixosConfigurations.nixos.options'';
              home_manager.expr = ''(builtins.getFlake "/home/manzi/nix").nixosConfigurations.nixos.options.home-manager.users.type.getSubOptions [ ]'';
            };
          };
        };

        # ---------- lua ----------
        lua_ls = {
          enable = true;
          config.settings.Lua = {
            runtime.version = "LuaJIT";
            diagnostics.globals = [ "vim" ];
            workspace.checkThirdParty = false;
            telemetry.enable = false;
            # stylua owns formatting (see format.nix).
            format.enable = false;
          };
        };

        # ---------- python ----------
        basedpyright = {
          enable = true;
          config.settings.basedpyright.analysis = {
            typeCheckingMode = "standard";
            diagnosticMode = "openFilesOnly";
            inlayHints = {
              variableTypes = true;
              functionReturnTypes = true;
            };
          };
        };

        # ---------- rust / tauri ----------
        # A Tauri app is this server for src-tauri plus the web servers above
        # for the frontend; nothing extra is needed.
        rust_analyzer = {
          enable = true;
          config.settings."rust-analyzer" = {
            cargo.allFeatures = true;
            check.command = "clippy";
            procMacro.enable = true;
            inlayHints = {
              parameterHints.enable = true;
              typeHints.enable = true;
            };
          };
        };

        # ---------- kotlin ----------
        kotlin_language_server.enable = true;

        # ---------- php / laravel ----------
        # nixvim lists intelephense as unpackaged, so the package is pointed at
        # nixpkgs explicitly. Intelephense understands Laravel's structure far
        # better than phpactor; phpactor is still on PATH (see format.nix) for
        # its refactoring CLI.
        intelephense = {
          enable = true;
          package = pkgs.intelephense;
          config.settings.intelephense.files.maxSize = 5000000;
        };

        # ---------- config files ----------
        marksman.enable = true; # markdown
        taplo.enable = true; # toml
        dockerls.enable = true;
        bashls.enable = true;
      };
    };
  };

  # Toolchains and SDKs.
  #
  # Language *servers* are wrapped onto nvim's own PATH by the options above.
  # The heavy SDKs below go on the user's PATH instead: nvim inherits them, but
  # they do not get baked into the editor wrapper, which keeps the nvim closure
  # from pulling in a JDK and the Flutter engine on every rebuild. They are
  # still fully declared here, so the environment stays reproducible - move any
  # of them into a per-project devShell if you want project-pinned versions.
  home.packages = with pkgs; [
    # C / C++ / Qt / CMake
    clang-tools # clangd, clang-format, clang-tidy
    gdb
    cmake
    ninja
    kdePackages.qtdeclarative # qmlls, qmlformat, qmllint

    # Rust / Tauri
    rustc
    cargo
    rustfmt
    clippy
    cargo-tauri

    # JVM
    jdk21
    gradle
    maven

    # Dart / Flutter
    flutter

    # PHP / Laravel
    php
    phpPackages.composer
    phpactor

    # SQL
    sqlite
  ];
}
