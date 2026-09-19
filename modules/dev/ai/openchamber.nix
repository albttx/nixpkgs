{ pkgs, ... }:

{
  # OpenChamber is the web/PWA workspace for OpenCode. The CLI is packaged
  # in overlays/openchamber because it is not in nixpkgs. Desktop on macOS
  # is the Homebrew cask in machines/mbp-albttx/homebrew.nix.
  home.packages = [ pkgs.openchamber ];
}
