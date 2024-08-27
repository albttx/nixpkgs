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
        sha256 = "sha256-TUrMOEIuw7K4YiR8y6JE0Erlmj7O8H5LGtDC0tI1VE8=";
      };
    in concatStringsSep "\n" [
      (readFile (gpakosz-tmux + "/.tmux.conf"))
      (readFile (./configs/tmux.conf.local))
      # (readFile (gpakosz-tmux + "/.tmux.conf.local"))
    ];
  };

}
