# cliamp-flake

Nix flake for [cliamp](https://github.com/bjarneo/cliamp), a terminal music player by [Bjarne Øverli](https://twitter.com/iamdothash).

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

### Use in a NixOS or home-manager configuration

Add the flake as an input. To always follow the latest version:

```nix
inputs.cliamp.url = "github:CarlosMendonca/cliamp-flake";
```

To pin a specific version:

```nix
inputs.cliamp.url = "github:CarlosMendonca/cliamp-flake?ref=v1.21.4";
```

To reuse your existing nixpkgs instead of pulling in a separate one:

```nix
inputs.cliamp.inputs.nixpkgs.follows = "nixpkgs";
```

Then add the package:

```nix
environment.systemPackages = [ inputs.cliamp.packages.${system}.cliamp ];
# or in home-manager:
home.packages = [ inputs.cliamp.packages.${system}.cliamp ];
```

### Build locally

```bash
git clone https://github.com/CarlosMendonca/cliamp-flake
cd cliamp-flake
nix build
./result/bin/cliamp
```

## Current version

cliamp [v1.33.8](https://github.com/bjarneo/cliamp/releases/tag/v1.33.8)
