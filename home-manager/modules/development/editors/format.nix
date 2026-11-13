{ lib, pkgs, ... }:
{
  # Formatting (conform.nvim) and linting (nvim-lint).
  #
  # Both modules have an `autoInstall` option, which is the direct replacement
  # for Mason: every tool named in `formatters_by_ft` / `lintersByFt` is
  # resolved to a nixpkgs package and added to nvim's PATH at build time.
  # Resolution order is `autoInstall.overrides.<name>`, then nixvim's own
  # package map, then `pkgs.<name>`. Warnings are left on, so a tool that
  # cannot be resolved shows up as a build warning rather than failing silently
  # the first time you save a file.
  programs.nixvim = {
    # Laravel Blade templates are not detected by default.
    filetype.pattern.".*%.blade%.php" = "blade";

    plugins = {
      conform-nvim = {
        enable = true;

        autoInstall = {
          enable = true;
          enableWarnings = true;

          overrides = {
            # nixvim's map points qmlformat at Qt5's qtdeclarative. Everything
            # else here is Qt6 (Plasma 6), so override it.
            qmlformat = pkgs.kdePackages.qtdeclarative;

            # Defined by hand below, so there is nothing to resolve.
            blade_formatter = null;
          };
        };

        settings = {
          format_on_save = {
            # Fall back to the language server for filetypes with no formatter
            # listed below - this is what formats PHP, via intelephense.
            lsp_format = "fallback";
            timeout_ms = 2000;
          };

          formatters_by_ft = {
            lua = [ "stylua" ];
            nix = [ "nixfmt" ];

            # --- web ---
            javascript = [ "prettierd" ];
            javascriptreact = [ "prettierd" ];
            typescript = [ "prettierd" ];
            typescriptreact = [ "prettierd" ];
            vue = [ "prettierd" ];
            svelte = [ "prettierd" ];
            astro = [ "prettierd" ];
            html = [ "prettierd" ];
            css = [ "prettierd" ];
            scss = [ "prettierd" ];
            less = [ "prettierd" ];
            json = [ "prettierd" ];
            jsonc = [ "prettierd" ];
            yaml = [ "prettierd" ];
            markdown = [ "prettierd" ];
            graphql = [ "prettierd" ];

            # --- C / C++ / Qt / CMake ---
            c = [ "clang_format" ];
            cpp = [ "clang_format" ];
            objc = [ "clang_format" ];
            objcpp = [ "clang_format" ];
            cuda = [ "clang_format" ];
            cmake = [ "cmake_format" ];
            qml = [ "qmlformat" ];

            # --- other languages ---
            python = [
              "ruff_organize_imports"
              "ruff_format"
            ];
            rust = [ "rustfmt" ];
            java = [ "google-java-format" ];
            kotlin = [ "ktfmt" ];
            dart = [ "dart_format" ];
            sql = [ "sql_formatter" ];
            blade = [ "blade_formatter" ];
            toml = [ "taplo" ];
            sh = [ "shfmt" ];
            bash = [ "shfmt" ];

            # Anything with no formatter at least loses trailing whitespace.
            "_" = [ "trim_whitespace" ];
          };

          formatters = {
            # blade-formatter's nixpkgs attribute is hyphenated, so it cannot be
            # resolved from the conform formatter name; point at it directly.
            blade_formatter = {
              command = lib.getExe pkgs.blade-formatter;
              # --stdin reads the buffer on stdin and prints the result; it
              # must not be combined with --write, which edits a file in place.
              args = [ "--stdin" ];
              stdin = true;
            };

            shfmt.prepend_args = [
              "-i"
              "2"
              "-ci"
            ];
          };
        };
      };

      lint = {
        enable = true;

        autoInstall = {
          enable = true;
          enableWarnings = true;
        };

        # Linters only where a language server isn't already reporting
        # diagnostics - eslint, clangd, ruff and intelephense cover their own
        # languages through LSP, so duplicating them here would double every
        # warning.
        lintersByFt = {
          sh = [ "shellcheck" ];
          bash = [ "shellcheck" ];
          sql = [ "sqlfluff" ];
          kotlin = [ "ktlint" ];
          cmake = [ "cmakelint" ];
          dockerfile = [ "hadolint" ];
        };
      };
    };
  };
}
