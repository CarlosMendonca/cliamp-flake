# Builds a single cliamp package from one data/cliamp.json entry.
#
# cliamp is a Go program built from source with buildGoModule, so each release
# carries two content hashes: `srcHash` (the fetched source tree) and
# `vendorHash` (the vendored Go module set). Both are platform-independent, so
# this same recipe builds on every system in `eachDefaultSystem`.
{
  pkgs,
  lib,
  entry,
}:

let
  inherit (entry) version srcHash vendorHash;
in
pkgs.buildGoModule {
  pname = "cliamp";
  inherit version;

  nativeBuildInputs = [ pkgs.pkg-config ];

  buildInputs = [
    pkgs.alsa-lib
    pkgs.libogg
    pkgs.libvorbis
    pkgs.flac
    pkgs.libmpg123
  ];

  src = pkgs.fetchFromGitHub {
    owner = "bjarneo";
    repo = "cliamp";
    rev = "v${version}";
    hash = srcHash;
  };

  inherit vendorHash;

  ldflags = [ "-X main.version=v${version}" ];

  meta = {
    description = "A terminal music player built with Bubbletea, Lip Gloss, Beep, and go-librespot";
    homepage = "https://github.com/bjarneo/cliamp";
    license = lib.licenses.mit;
    mainProgram = "cliamp";
  };
}
