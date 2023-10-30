{ pkgs, inputs, ... }: {
  # home.file.".tmux.conf".source = "${inputs.gpakosz-tmux}/.tmux.conf";
  # home.file.".tmux.conf.local".source = ./configs/tmux.conf.local;

  programs.tmux = {
    enable = true;
    plugins = with pkgs.tmuxPlugins; [ tmux-fzf ];
  };
}
