{ config, pkgs, ... }:
let
  # Rider bundles its own copy of this SDK for the ReSharper host (see its
  # postInstall in nixpkgs), but that one is private to the IDE. Projects need
  # an SDK of their own, and `dotnet` on PATH is how both Rider and the shell
  # find it.
  dotnet = pkgs.dotnetCorePackages.sdk_10_0;

  # Studio's own SDK Manager owns this directory. It is deliberately not a nix
  # store path: `android-studio-full` would give a declarative SDK, but that
  # one is read-only, so in-IDE SDK and NDK updates fail against it.
  androidSdk = "${config.home.homeDirectory}/Android/Sdk";
in
{
  home.packages = [
    # `jetbrains.idea` is the former idea-ultimate: JetBrains folded the
    # editions into a single distribution, so nixpkgs renamed the attribute and
    # removed idea-community outright. `jetbrains.idea-oss` is the remaining
    # free option, but it is a source build.
    pkgs.jetbrains.rider
    pkgs.jetbrains.idea
    pkgs.android-studio

    # `programs.adb.enable` no longer exists - nixpkgs 26.05 moved it to
    # rename.nix with the note that systemd 258 handles the uaccess rules
    # automatically and the package alone is now enough. So no adbusers group
    # and no udev rules here. /dev/kvm is already 0666, so the emulator needs
    # nothing either.
    pkgs.android-tools

    dotnet

    # The Kotlin language server is already wrapped onto nvim's PATH by
    # editors/lsp.nix; this is the compiler, for use outside the IDEs.
    pkgs.kotlin
  ];

  # jdk21, gradle and maven are intentionally absent: editors/lsp.nix already
  # installs them for the JVM language servers, and declaring a package in two
  # modules collides when the user profile is built.

  # These reach shells only - home-manager writes them into .zshenv and
  # .profile. Applications launched from the Plasma launcher source neither,
  # but they do not need to: /etc/set-environment puts
  # /etc/profiles/per-user/$USER/bin on the session PATH, so the IDEs find
  # `dotnet` and `adb` either way, and Studio records its SDK location in its
  # own config rather than reading ANDROID_HOME.
  home.sessionVariables = {
    DOTNET_ROOT = "${dotnet}/share/dotnet";
    ANDROID_HOME = androidSdk;
    # Superseded by ANDROID_HOME upstream, but Gradle plugins still read it.
    ANDROID_SDK_ROOT = androidSdk;
  };
}
