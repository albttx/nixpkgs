{ inputs, config, pkgs, lib, nix-doom-emacs, ... }:

{
  users.users.runner = {
    name = "runner";
    home = "/Users/runner";
    description = "runner";
    shell = pkgs.zsh;
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;

    users.runner = {
      home.stateVersion = "23.05";

      imports = [
        ../../modules/ssh
        ../../modules/git
        ../../modules/gpg

        # # terminal
        ../../modules/terminal/kitty

        # # programming
        ../../modules/dev

        # # import zsh, fxf, tmux config
        ../../modules/shells

        # # import editors
        # ../../modules/emacs
        # ../../modules/vscode
        # ../../modules/zed

      ];

      programs.zsh = {
        initContent = ''
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

      # disabled fzf
      home.activation.generateFzFMarks = lib.mkForce "";

    };
  };
}
