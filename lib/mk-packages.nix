# Builds the full attrset of cliamp packages for `pkgs`' own system: one
# `cliamp_<version>` per release, plus a `cliamp` alias for the newest and a
# `default`. Shared by `packages.<system>` and `overlays.default` so the two can
# never drift apart.
{
  pkgs,
  lib,
  cliampData,
}:

let
  sanitize = import ./sanitize.nix;

  mkCliamp = entry: import ./mk-cliamp.nix { inherit pkgs lib entry; };

  # `cliamp_<sanitized version>` for every release. cliamp is built from source,
  # so every entry is valid on every system -- no per-system filtering needed.
  named = lib.listToAttrs (
    map (e: {
      name = "cliamp_${sanitize e.version}";
      value = mkCliamp e;
    }) cliampData
  );

  # Highest version in the data set (null if the list is somehow empty).
  latest =
    if cliampData == [ ] then
      null
    else
      lib.foldl' (
        acc: e: if builtins.compareVersions e.version acc.version > 0 then e else acc
      ) (builtins.head cliampData) cliampData;
in
named
# `cliamp` -> newest release; `default` so a plain `nix run`/`nix build` works.
// lib.optionalAttrs (latest != null) {
  cliamp = mkCliamp latest;
  default = mkCliamp latest;
}
