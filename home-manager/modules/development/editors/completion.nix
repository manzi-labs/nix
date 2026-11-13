{ ... }:
{
  # Completion popup and snippets.
  #
  # nvim-cmp's source modules are separate plugins named after themselves
  # (`plugins.cmp-nvim-lsp`, `plugins.cmp_luasnip`, ...). They do not need to be
  # enabled by hand: `plugins.cmp.autoEnableSources` defaults to true, so
  # naming a source in `settings.sources` pulls in its plugin.
  #
  # Copilot is not a source here on purpose - it provides inline ghost text
  # instead (see copilot.nix), and nixvim warns if you try to do both.
  programs.nixvim.plugins = {

    luasnip = {
      enable = true;
      settings = {
        history = true;
        update_events = [
          "TextChanged"
          "TextChangedI"
        ];
      };
    };

    # ~1000 community snippets for the whole web stack and beyond. Enabling
    # this module wires `luasnip.fromVscode` by itself.
    friendly-snippets.enable = true;

    cmp = {
      enable = true;

      settings = {
        snippet.expand = "function(args) require('luasnip').lsp_expand(args.body) end";

        completion.completeopt = "menu,menuone,noinsert";

        window = {
          completion.border = "rounded";
          documentation.border = "rounded";
        };

        # Order is priority order: LSP first, then snippets, then the
        # cheap-but-noisy sources.
        sources = [
          { name = "nvim_lsp"; }
          { name = "luasnip"; }
          {
            name = "buffer";
            keyword_length = 3;
          }
          { name = "path"; }
        ];

        mapping = {
          "<C-Space>" = "cmp.mapping.complete()";
          "<C-e>" = "cmp.mapping.abort()";
          "<CR>" = "cmp.mapping.confirm({ select = false })";
          "<C-b>" = "cmp.mapping.scroll_docs(-4)";
          "<C-f>" = "cmp.mapping.scroll_docs(4)";
          "<C-n>" = "cmp.mapping.select_next_item()";
          "<C-p>" = "cmp.mapping.select_prev_item()";

          # Tab cycles the menu, expands/jumps a snippet, or falls through.
          "<Tab>" = ''
            cmp.mapping(function(fallback)
              local luasnip = require("luasnip")
              if cmp.visible() then
                cmp.select_next_item()
              elseif luasnip.expand_or_locally_jumpable() then
                luasnip.expand_or_jump()
              else
                fallback()
              end
            end, { "i", "s" })
          '';

          "<S-Tab>" = ''
            cmp.mapping(function(fallback)
              local luasnip = require("luasnip")
              if cmp.visible() then
                cmp.select_prev_item()
              elseif luasnip.locally_jumpable(-1) then
                luasnip.jump(-1)
              else
                fallback()
              end
            end, { "i", "s" })
          '';
        };
      };
    };
  };
}
