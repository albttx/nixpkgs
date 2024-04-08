{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    # basic rust tools
    # cargo
    # cargo-edit
    # cargo-generate
    # cargo-watch
    # cargo-xbuild
    # clang
    # rustc

    rustup
    # rustfmt
    cargo-generate
    # rust-analyzer
  ];
}
