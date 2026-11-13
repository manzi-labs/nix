# Shared builder for the ArtCraft apps that are not in nixpkgs yet.
#
# Upstream (github.com/storytold - the org is called "ArtCraft"; its display
# name is not "ArtCraft Studio", which is a different and unrelated GitHub org)
# ships every app through an identical release matrix, and every AppImage has
# the same internal layout:
#
#   AppRun                                        -> usr/bin/<pname>
#   usr/bin/<pname>, usr/bin/<pname>-cli
#   usr/share/applications/ai.storyteller.<pname>.desktop   Exec=<pname>
#   usr/share/mime/packages/ai.storyteller.<pname>.xml
#   usr/share/icons/hicolor/{16x16..256x256,scalable}
#
# so one function covers all of them. Verified by extracting all five.
#
# These are stopgaps. Each app has an open nixpkgs PR; when one merges, delete
# the entry from ./default.nix and take the app from nixpkgs instead - a source
# build gets proper rpaths and Hydra binaries instead of a vendored blob.
{
  lib,
  appimageTools,
  fetchurl,
}:

{
  pname,
  version,
  hash,
  description,
}:

let
  src = fetchurl {
    url = "https://github.com/storytold/${pname}/releases/download/v${version}/${pname}-${version}-linux-x86_64.AppImage";
    inherit hash;
  };

  # Only used to lift the desktop entry, icons and MIME rules back out; the
  # wrapper below runs the AppImage itself.
  contents = appimageTools.extractType2 { inherit pname version src; };
in
appimageTools.wrapType2 {
  inherit pname version src;

  # No extraPkgs: appimageTools' own FHS list already carries everything these
  # egui/wgpu apps dlopen - vulkan-loader, wayland, libxkbcommon, libGL, dbus,
  # alsa-lib and pipewire are all in `defaultFhsEnvArgs.multiPkgs`. The GPU
  # reaches the sandbox because bubblewrap bind-mounts every unignored top-level
  # directory, so /run/opengl-driver comes along, its share/ goes on
  # XDG_DATA_DIRS for Vulkan ICD discovery, and nvidia_icd.json points at an
  # absolute /nix path that is bind-mounted too.

  # Upstream already writes `Exec=<pname>`, which is exactly what the wrapper
  # installs as $out/bin/<pname>, so the entry needs no rewriting.
  extraInstallCommands = ''
    install -Dm444 ${contents}/usr/share/applications/ai.storyteller.${pname}.desktop \
      -t $out/share/applications

    mkdir -p $out/share
    cp -r ${contents}/usr/share/icons $out/share/

    # Not every app claims file types - CraftAnything ships no MIME package at
    # all - and the metainfo is only there for AppStream, so neither is
    # assumed to exist.
    if [ -d ${contents}/usr/share/mime/packages ]; then
      install -Dm444 ${contents}/usr/share/mime/packages/*.xml -t $out/share/mime/packages
    fi

    if [ -d ${contents}/usr/share/metainfo ]; then
      install -Dm444 ${contents}/usr/share/metainfo/*.xml -t $out/share/metainfo
    fi
  '';

  meta = {
    inherit description;
    homepage = "https://github.com/storytold/${pname}";
    changelog = "https://github.com/storytold/${pname}/releases/tag/v${version}";
    license = with lib.licenses; [
      # The code is MIT OR Apache-2.0. The bundled fonts and assets add their
      # own terms on top - see share/doc/${pname} inside the AppImage.
      mit
      asl20
      ofl
    ];
    mainProgram = pname;
    # Only the x86_64 asset is wrapped here, though upstream also builds
    # aarch64, riscv64 and FreeBSD.
    platforms = [ "x86_64-linux" ];
  };
}
