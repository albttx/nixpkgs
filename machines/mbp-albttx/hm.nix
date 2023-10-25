{ inputs, config, pkgs, lib, nix-doom-emacs, ... }:

{
  users.users.albttx = {
    home = "/Users/albttx";
    description = "albttx";
    shell = pkgs.zsh;
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.albttx = {
      home.stateVersion = "23.05";

      imports = [
        nix-doom-emacs.hmModule

        ../../modules/ssh
        ../../modules/git
        ../../modules/gpg

        # terminal
        ../../modules/terminal/kitty

        # programming
        ../../modules/dev/go.nix
        ../../modules/dev/nodejs.nix
        ../../modules/dev/direnv.nix

        # import zsh, fxf, tmux config
        ../../modules/shells/default.nix

        # import editors
        ../../modules/emacs
      ];
      programs.zsh = {
        initExtra = ''
          eval "$(/opt/homebrew/bin/brew shellenv)"
        '';
      };

      programs.home-manager.enable = true;

      home.packages = with pkgs; [ coreutils curl wget ];

    };
  };
}
