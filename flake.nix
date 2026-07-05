{
  description = "cliamp - a terminal music player, version-selectable";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    let
      # Single source of truth for every packaged release.
      cliampData = builtins.fromJSON (builtins.readFile ./data/cliamp.json);

      mkPackages =
        pkgs:
        import ./lib/mk-packages.nix {
          inherit pkgs cliampData;
          lib = pkgs.lib;
        };
    in
    {
      # Fold every cliamp_*/cliamp package into a consumer's nixpkgs. Build from
      # `prev` (leaf packages that don't reference other cliamp packages), and drop
      # the `default` alias so consumers don't get a stray `pkgs.default`.
      overlays.default = _final: prev: removeAttrs (mkPackages prev) [ "default" ];
    }
    // flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        # `nix run .#update` appends the newest cliamp release to data/cliamp.json.
        update = pkgs.writeShellApplication {
          name = "cliamp-update";
          runtimeInputs = [
            pkgs.curl
            pkgs.jq
            pkgs.coreutils
            pkgs.gnugrep
            pkgs.nix
          ];
          text = ''exec bash ${./updater/update.sh} "$@"'';
        };
      in
      {
        packages = mkPackages pkgs;

        apps.cliamp = flake-utils.lib.mkApp {
          drv = self.packages.${system}.cliamp;
        };
        apps.default = self.apps.${system}.cliamp;

        apps.update = {
          type = "app";
          program = "${update}/bin/cliamp-update";
          meta.description = "Append the newest cliamp release to data/cliamp.json";
        };

        formatter = pkgs.nixfmt;
      }
    );
}
