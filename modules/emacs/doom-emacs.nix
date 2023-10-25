#  Doom Emacs: Personally not a fan of github:nix-community/nix-doom-emacs due to performance issues
#  This is an ideal way to install on a vanilla NixOS installion.
#  You will need to import this from somewhere in the flake (Obviously not in a home-manager nix file)
#
#  flake.nix
#   ├─ ./hosts
#   │   └─ configuration.nix
#   └─ ./modules
#       └─ ./editors
#           ├─ default.nix
#           └─ ./emacs
#               └─ ./doom-emacs
#                   └─ default.nix *
#

{ config, pkgs, ... }:

{
  #services.emacs.enable = true;

  system.activationScripts = {
    doomEmacs = {
      text = ''
        source ${config.system.build.setEnvironment}
        EMACS="$HOME/.doom.d"

        if [ ! -d "$EMACS" ]; then
          ${pkgs.git}/bin/git clone https://github.com/hlissner/doom-emacs.git $EMACS
          yes | $EMACS/bin/doom install
          rm -r $HOME/.doom.d
          ln -s $$HOME/go/src/github.com/albttx/nixpkgs/modules/editors/emacs/doom-emacs/doom.d $HOME/.doom.d
          $EMACS/bin/doom sync
        else
          $EMACS/bin/doom sync
        fi
      '';
    };
  };

  environment.systemPackages = with pkgs; [
    clang
    coreutils
    # emacs
    fd
    git
    ripgrep
  ];
}
