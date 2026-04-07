{
  description = "cliamp - a terminal music player";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        version = "1.35.0";
      in {
        packages.cliamp = pkgs.buildGoModule {
          pname = "cliamp";
          inherit version;

          nativeBuildInputs = [ pkgs.pkg-config ];

          buildInputs = [
            pkgs.alsa-lib
            pkgs.libogg
            pkgs.libvorbis
            pkgs.flac
          ];

          src = pkgs.fetchFromGitHub {
            owner = "bjarneo";
            repo = "cliamp";
            rev = "v1.35.0";
            hash = "sha256-8Att+SEJd2MdAgQ8SM49S4c4fM7t0/f/kHl6a+DbO2U=";
          };

          vendorHash = "sha256-sS0tjZoZ81Jwn/KJnJD01fTA4z0HxEYYM89Ta398MP0=";

          ldflags = [ "-X main.version=v${version}" ];

          meta = {
            description = "A terminal music player built with Bubbletea, Lip Gloss, Beep, and go-librespot";
            homepage = "https://github.com/bjarneo/cliamp";
            license = pkgs.lib.licenses.mit;
            mainProgram = "cliamp";
          };
        };

        packages.default = self.packages.${system}.cliamp;

        apps.cliamp = flake-utils.lib.mkApp {
          drv = self.packages.${system}.cliamp;
        };

        apps.default = self.apps.${system}.cliamp;
      });
}
