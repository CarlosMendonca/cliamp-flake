# Turn an upstream version string into a valid (and readable) Nix attr suffix.
#   "1.57.1"   -> "1_57_1"
#   "1.57.1-1" -> "1_57_1_1"
version: builtins.replaceStrings [ "." "-" "+" ] [ "_" "_" "_" ] version
