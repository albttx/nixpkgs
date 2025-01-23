{ pkgs, inputs, lib, ... }:
with builtins // lib; {
  # home.file.".tmux.conf".source = "${inputs.gpakosz-tmux}/.tmux.conf";
  home.file.".tmux.conf.local".source = ./configs/tmux.conf.local;

  # programs.tmux = {
  #   enable = true;
  #   plugins = with pkgs.tmuxPlugins; [ tmux-fzf ];
  # };

  programs.tmux = {
    enable = true;
    plugins = with pkgs.tmuxPlugins; [ tmux-fzf ];
    extraConfig = let
      gpakosz-tmux = pkgs.fetchFromGitHub {
        owner = "gpakosz";
        repo = ".tmux";
        rev = "master";
        sha256 = "sha256-TowIG+E2+zLsQgLFduchAllHxowZCLT3tDL7+8K9xeQ=";
      };
    in concatStringsSep "\n" [
      (readFile (gpakosz-tmux + "/.tmux.conf"))
      (readFile (./configs/tmux.conf.local))
      # (readFile (gpakosz-tmux + "/.tmux.conf.local"))
    ];
  };

}
