# cliamp-flake

Nix flake for [cliamp](https://github.com/bjarneo/cliamp), a terminal music player by [Bjarne Øverli](https://twitter.com/iamdothash).

Every release is exposed as its own package attribute (`cliamp_1_57_1`), and `cliamp`/`default` always track the newest.

## Usage

### Run without installing

```bash
nix run github:CarlosMendonca/cliamp-flake
```

### Try in a temporary shell

```bash
nix shell github:CarlosMendonca/cliamp-flake
cliamp
```

### Run or install a specific version

Each release is available as `cliamp_<version>`, with dots replaced by underscores:

```bash
nix run   github:CarlosMendonca/cliamp-flake#cliamp_1_21_4
nix shell github:CarlosMendonca/cliamp-flake#cliamp_1_57_1
nix profile install github:CarlosMendonca/cliamp-flake#cliamp_1_57_1
```

### Use in a NixOS or home-manager configuration

Add the flake as an input:

```nix
inputs.cliamp.url = "github:CarlosMendonca/cliamp-flake";
```

To reuse your existing nixpkgs instead of pulling in a separate one:

```nix
inputs.cliamp.inputs.nixpkgs.follows = "nixpkgs";
```

Then add a package — either the latest or a pinned version:

```nix
environment.systemPackages = [
  inputs.cliamp.packages.${system}.cliamp          # newest
  # inputs.cliamp.packages.${system}.cliamp_1_21_4 # a specific release
];
# or in home-manager:
home.packages = [ inputs.cliamp.packages.${system}.cliamp ];
```

### As an overlay

Apply `overlays.default` to fold every version into your `pkgs`:

```nix
nixpkgs.overlays = [ inputs.cliamp.overlays.default ];
# then, anywhere pkgs is in scope:
environment.systemPackages = [
  pkgs.cliamp          # newest
  # pkgs.cliamp_1_21_4 # a specific release
];
```

### Legacy version pinning

Older releases remain reachable through git-tag pinning as well:

```nix
inputs.cliamp.url = "github:CarlosMendonca/cliamp-flake?ref=v1.21.4";
```

### Build locally

```bash
git clone https://github.com/CarlosMendonca/cliamp-flake
cd cliamp-flake
nix build
./result/bin/cliamp
```

## Adding a new release

`data/cliamp.json` is the single source of truth. To append the latest upstream release (computing its `srcHash` and `vendorHash`):

```bash
nix run .#update
```

This runs automatically every two hours via GitHub Actions.

## Current version

cliamp [v2.0.1](https://github.com/bjarneo/cliamp/releases/tag/v2.0.1)
