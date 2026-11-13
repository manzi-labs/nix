{ lib, pkgs, ... }:
let
  keymapName = "Shared Development";

  ideaConfig = "JetBrains/IntelliJIdea${lib.versions.majorMinor pkgs.jetbrains.idea.version}";
  riderConfig = "JetBrains/Rider${lib.versions.majorMinor pkgs.jetbrains.rider.version}";
  androidStudioVersion = lib.concatStringsSep "." (
    lib.take 3 (lib.splitString "." pkgs.android-studio.version)
  );
  androidStudioConfig = "Google/AndroidStudio${androidStudioVersion}";

  jetbrainsKeymap = ''
    <keymap version="1" name="${keymapName}" parent="Visual Studio">
      <action id="GotoDeclaration">
        <keyboard-shortcut first-keystroke="F12" />
      </action>
      <action id="RenameElement">
        <keyboard-shortcut first-keystroke="control R" second-keystroke="R" />
        <keyboard-shortcut first-keystroke="control R" second-keystroke="control R" />
      </action>
      <action id="PreviousTab">
        <keyboard-shortcut first-keystroke="alt H" />
      </action>
      <action id="NextTab">
        <keyboard-shortcut first-keystroke="alt L" />
      </action>
      <action id="NextSplitter">
        <keyboard-shortcut first-keystroke="alt J" />
      </action>
      <action id="PrevSplitter">
        <keyboard-shortcut first-keystroke="alt K" />
      </action>
    </keymap>
  '';

  jetbrainsKeymapSelection = ''
    <application>
      <component name="KeymapManager">
        <active_keymap name="${keymapName}" />
      </component>
    </application>
  '';

  jetbrainsConfigFiles = lib.listToAttrs (
    lib.concatMap
      (configRoot: [
        {
          name = "${configRoot}/keymaps/${keymapName}.xml";
          value.text = jetbrainsKeymap;
        }
        {
          name = "${configRoot}/options/keymap.xml";
          value.text = jetbrainsKeymapSelection;
        }
      ])
      [
        ideaConfig
        riderConfig
        androidStudioConfig
      ]
  );
in
{
  programs.nixvim.keymaps = [
    {
      mode = "n";
      key = "<C-r>r";
      action = "<cmd>lua vim.lsp.buf.rename()<CR>";
      options = {
        desc = "Rename symbol";
        silent = true;
      };
    }
    {
      mode = "n";
      key = "<F12>";
      action = "<cmd>lua vim.lsp.buf.definition()<CR>";
      options = {
        desc = "Go to definition";
        silent = true;
      };
    }
    {
      mode = "n";
      key = "<A-h>";
      action = "<cmd>BufferLineCyclePrev<CR>";
      options = {
        desc = "Previous buffer";
        silent = true;
      };
    }
    {
      mode = "n";
      key = "<A-l>";
      action = "<cmd>BufferLineCycleNext<CR>";
      options = {
        desc = "Next buffer";
        silent = true;
      };
    }
    {
      mode = "n";
      key = "<A-j>";
      action = "<C-w>w";
      options.desc = "Next window";
    }
    {
      mode = "n";
      key = "<A-k>";
      action = "<C-w>W";
      options.desc = "Previous window";
    }
  ];

  xdg.configFile = jetbrainsConfigFiles;
}
