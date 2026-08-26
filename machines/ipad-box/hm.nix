{
  inputs,
  outputs,
  config,
  pkgs,
  lib,
  ...
}:

{
  users.users.albttx.shell = pkgs.zsh;
  # zsh must also be enabled system-side so it lands in /etc/shells.
  programs.zsh.enable = true;

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
    extraSpecialArgs = { inherit inputs outputs; };
    users.albttx = {
      home.stateVersion = "26.05";

      imports = [
        ../../modules/ssh
        ../../modules/git
        ../../modules/gpg

        # programming
        ../../modules/dev

        # import zsh, fzf, tmux config
        ../../modules/shells

        # import editors
        ../../modules/neovim
        ../../modules/emacs
      ];

      programs.home-manager.enable = true;

      # The GPG signing key only lives on the laptop; signing every commit
      # here would just fail.
      programs.git.signing.signByDefault = lib.mkForce false;

      home.packages = with pkgs; [
        # build tool
        coreutils
        curl
        wget

        # headless server: terminal emacs for the doom config
        emacs-nox
        my-libvterm
      ];
    };
  };
}
