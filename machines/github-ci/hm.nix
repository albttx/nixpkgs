{ inputs, config, pkgs, lib, nix-doom-emacs, ... }:

{
  users.users.github-ci = {
    home = "/Users/github-ci";
    description = "github-ci";
    shell = pkgs.zsh;
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.github-ci = {
      home.stateVersion = "23.05";

      imports = [
        ../../modules/ssh
        ../../modules/git
        ../../modules/gpg

        # terminal
        ../../modules/terminal/kitty

        # programming
        ../../modules/dev

        # import zsh, fxf, tmux config
        ../../modules/shells

        # import editors
        ../../modules/emacs
        # ../../modules/vscode
        # ../../modules/zed

      ];
      programs.zsh = {
        initExtra = ''
          eval "$(/opt/homebrew/bin/brew shellenv)"
        '';
      };

      programs.home-manager.enable = true;

      home.packages = with pkgs; [
        # build tool
        coreutils
        curl
        wget

        my-libvterm
      ];

    };
  };
}
