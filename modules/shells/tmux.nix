{
  pkgs,
  inputs,
  lib,
  ...
}:
with builtins // lib;
{
  # home.file.".tmux.conf".source = "${inputs.gpakosz-tmux}/.tmux.conf";
  home.file.".config/tmux/tmux.conf.local".source = ./configs/tmux.conf.local;

  # programs.tmux = {
  #   enable = true;
  #   plugins = with pkgs.tmuxPlugins; [ tmux-fzf ];
  # };

  programs.tmux = {
    enable = true;
    plugins = with pkgs.tmuxPlugins; [ tmux-fzf ];
    extraConfig =
      let
        gpakosz-tmux = pkgs.fetchFromGitHub {
          owner = "gpakosz";
          repo = ".tmux";
          # pinned: rev = "master" breaks with a hash mismatch every time
          # upstream moves (master of 2026-08-08)
          rev = "58a3dcc0d718ec0fa1c0d5a2fddd640a1ad7a5b7";
          sha256 = "sha256-YDzbZVFhrAMBhOI8HVDxR3rEPkrEwG57IUbnZicmfn4=";
        };
      in
      concatStringsSep "\n" [
        (readFile (gpakosz-tmux + "/.tmux.conf"))
        # (readFile (./configs/tmux.conf.local))
        # (readFile (gpakosz-tmux + "/.tmux.conf.local"))
      ];
  };

}
