{ lib, pkgs, ... }:
{
  # GitHub Copilot, as inline ghost-text suggestions.
  #
  # Authentication is the one thing in this whole editor config that cannot be
  # declared: nixvim exposes no option for Copilot tokens, and there is no
  # credential path to point at. Run `:Copilot auth` once after the first
  # rebuild; the token is written to ~/.config/github-copilot/ and is a
  # per-user secret, which is where it belongs rather than in the store.
  # It is separate from the token used by `gh` and github-copilot-cli.
  #
  # Suggestions are shown inline only. copilot-cmp (Copilot as a completion
  # source) is deliberately not enabled - nixvim warns when it is combined with
  # `suggestion.enabled`, and inline ghost text is the point here.
  programs.nixvim = {
    plugins.copilot-lua = {
      enable = true;

      # nixpkgs 26.05 fetches this plugin by git *tag*, and upstream
      # force-moved the v2.0.4 tag after nixpkgs recorded its hash. The stock
      # package therefore fails to build with a fixed-output hash mismatch:
      #
      #   specified: sha256-+hQ4Og0ZZS/tvs4z5733qRu5+W4D24HgHHPIL5vd0Eo=
      #   got:       sha256-05f76OeWBlFmlUh90tH4XMMKfNI1jnhuIJDqYPPQokA=
      #
      # Pin the commit that v2.0.4 now points at instead. A commit is
      # immutable, so unlike the tag this cannot drift again. Drop this
      # override once nixpkgs corrects the hash.
      package = pkgs.vimPlugins.copilot-lua.overrideAttrs (_: {
        src = pkgs.fetchFromGitHub {
          owner = "zbirenbaum";
          repo = "copilot.lua";
          rev = "b1482409cefe8b201f89122c682189fabf0436da";
          hash = "sha256-05f76OeWBlFmlUh90tH4XMMKfNI1jnhuIJDqYPPQokA=";
        };
      });

      settings = {
        # copilot.lua 2.x defaults to `type = "nodejs"`, which looks for a
        # bundled `copilot/js/language-server.js` on the runtimepath. That file
        # is not shipped in the plugin's source tree, so on nixpkgs the default
        # silently fails: the LSP client never starts, and `:Copilot auth` then
        # does nothing because there is no client to authenticate against.
        #
        # nixpkgs packages the server as a standalone binary instead, so use
        # the plugin's "binary" mode and point it at the store path.
        server = {
          type = "binary";
          custom_server_filepath = lib.getExe pkgs.copilot-language-server;
        };

        suggestion = {
          enabled = true;
          # Suggest as you type rather than only on keypress.
          auto_trigger = true;
          # Get out of the way while the nvim-cmp menu is open.
          hide_during_completion = true;
          debounce = 75;

          keymap = {
            accept = "<M-l>";
            accept_word = "<M-w>";
            accept_line = "<M-j>";
            next = "<M-]>";
            prev = "<M-[>";
            dismiss = "<C-]>";
          };
        };

        # The split panel view is redundant with inline suggestions.
        panel.enabled = false;

        # Don't send these buffers to Copilot.
        filetypes = {
          gitcommit = false;
          gitrebase = false;
          hgcommit = false;
          svn = false;
          cvs = false;
          help = false;
          "." = false;
        };

        # The plugin default for this is the bare string "node", which relies
        # on whatever happens to be on PATH. Pin it to the store instead.
        copilot_node_command = lib.getExe pkgs.nodejs_22;
      };
    };

    # copilot-lua declares curl and nodejs as dependencies and auto-enables
    # them; this pins the node version used for the wrapper's PATH entry.
    dependencies.nodejs.package = pkgs.nodejs_22;
  };
}
