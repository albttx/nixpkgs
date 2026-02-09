{
  inputs,
  config,
  pkgs,
  ...
}:

{
  imports = [
    ./zsh.nix
    ./fzf.nix
    ./tmux.nix
  ];

  # Htop
  # https://rycee.gitlab.io/home-manager/options.html#opt-programs.htop.enable
  programs.htop.enable = true;
  programs.htop.settings.show_program_path = true;

}
