{ config, pkgs, ... }:

{
  # Git worktree + tmux orchestrator for parallel agent work.
  # https://github.com/raine/workmux
  home.packages = [ pkgs.workmux ];

  programs.zsh.shellAliases.wm = "workmux";
}
