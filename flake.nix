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
        version = "1.27.5";
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
            rev = "v1.27.5";
            hash = "sha256-m5ElFv5u/tDcJ6o3lutjMxF3KXjWz+SYk4hanfiE0VQ=";
          };

          vendorHash = "sha256-UMDCpfSGfvJmI+sImaFzgZpLNaLMgEnmGCqERwPokHM=";

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
