{
  description = "cliamp - a terminal music player";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        version = "1.34.0";
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
            rev = "v1.34.0";
            hash = "sha256-0WT3DRII4o58KFK+7UW0QgrJwrJwmPkKmTQeVXmtoZ0=";
          };

          vendorHash = "sha256-+uh+4ZYvnlKmRSIvZFlnfBPqU0CFFe/Op1Gr9hjIr4U=";

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
