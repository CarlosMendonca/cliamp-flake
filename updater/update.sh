#!/usr/bin/env bash
# Appends the newest cliamp release to data/cliamp.json.
#
# cliamp is built from source, so a new entry needs two content hashes:
#   srcHash    - cheap: nix-prefetch-url on the release tarball, no build.
#   vendorHash - requires resolving the Go module set, so we use the fakeHash
#                trick: insert a provisional entry, let `nix build` fail on the
#                hash mismatch, and read the real hash out of the error.
#
# Run from the repo root (so `path:.` and $PWD/data resolve correctly).
#
# Env knobs (all optional):
#   CLIAMP_DATA_DIR   where cliamp.json lives   (default: $PWD/data)
#   GITHUB_TOKEN      bearer token to raise the GitHub API rate limit

set -euo pipefail

DATA_DIR="${CLIAMP_DATA_DIR:-$PWD/data}"
DATA="$DATA_DIR/cliamp.json"
REPO="bjarneo/cliamp"
FAKE_HASH="sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="

log() { printf '[cliamp-update] %s\n' "$*" >&2; }

gh_get() {
  local url="$1"
  local -a auth=()
  [[ -n "${GITHUB_TOKEN:-}" ]] && auth=(-H "Authorization: Bearer $GITHUB_TOKEN")
  curl -fsSL "${auth[@]}" -H "Accept: application/vnd.github+json" "$url"
}

# Numeric version sort, matching how data/cliamp.json is generated.
resort() {
  local f="$1" tmp
  tmp="$(mktemp)"
  jq 'unique_by(.version) | sort_by(.version | split(".") | map(tonumber))' "$f" >"$tmp"
  mv "$tmp" "$f"
}

[[ -f "$DATA" ]] || {
  log "no data file at $DATA"
  exit 1
}

LATEST_TAG="$(gh_get "https://api.github.com/repos/$REPO/releases/latest" | jq -r '.tag_name')"
VERSION="${LATEST_TAG#v}"
log "latest upstream release: $LATEST_TAG"

if jq -e --arg v "$VERSION" 'any(.[]; .version == $v)' "$DATA" >/dev/null; then
  log "$VERSION already present, nothing to do."
  exit 0
fi

log "computing srcHash for $LATEST_TAG"
URL="https://github.com/$REPO/archive/refs/tags/${LATEST_TAG}.tar.gz"
RAW="$(nix-prefetch-url --unpack --type sha256 "$URL" 2>/dev/null)"
SRC_HASH="$(nix hash convert --hash-algo sha256 --to sri "$RAW")"
log "srcHash: $SRC_HASH"

SAN="$(printf '%s' "$VERSION" | tr '.+-' '___')"
ATTR="cliamp_${SAN}"

# Insert a provisional entry with a fake vendorHash so `nix build` can tell us
# the real one.
tmp="$(mktemp)"
jq --arg v "$VERSION" --arg s "$SRC_HASH" --arg d "$FAKE_HASH" \
  '. + [{version:$v, srcHash:$s, vendorHash:$d}]' "$DATA" >"$tmp"
mv "$tmp" "$DATA"
resort "$DATA"

log "resolving vendorHash via build of .#$ATTR"
BUILD_OUTPUT="$(nix build "path:.#${ATTR}" 2>&1 || true)"
VENDOR_HASH="$(printf '%s\n' "$BUILD_OUTPUT" | grep -E '^\s+(got|hash):' | grep -oP 'sha256-\S+' | head -1 || true)"
if [[ -z "$VENDOR_HASH" ]]; then
  log "ERROR: could not extract vendorHash from build output:"
  printf '%s\n' "$BUILD_OUTPUT" >&2
  exit 1
fi
log "vendorHash: $VENDOR_HASH"

tmp="$(mktemp)"
jq --arg v "$VERSION" --arg d "$VENDOR_HASH" \
  'map(if .version == $v then .vendorHash = $d else . end)' "$DATA" >"$tmp"
mv "$tmp" "$DATA"

log "verifying build of .#$ATTR"
nix build "path:.#${ATTR}"

log "added $VERSION to $DATA ($(jq length "$DATA") entries)"
