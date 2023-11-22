{ inputs, config, lib, pkgs, nixos, system, ... }:

{
  # nixpkgs.overlays = [ inputs.emacs-overlay.overlay ];

  home.packages = with pkgs; [
    sqlite # required by magit

    # basics
    fd
    git

    # build tools
    clang
    cmake
    libtool
    coreutils
    # libvterm # installed with overlay my-libvterm

    #completion tools
    ripgrep
    silver-searcher

    # :searcher nix
    nixfmt

    # :lang javascript
    nodejs
    nodePackages.npm
    nodePackages.prettier
    nodePackages.typescript-language-server

    # TODO: install editor config
    #nodePackages.editorconfig
    bun

    # :lang bash
    shfmt

    ## lsp

    # syntax color
    emacs-all-the-icons-fonts
  ];

  home.file.".doom.d" = {
    source = ./doom.d;
    recursive = true;
    #onChange = builtins.readFile ./doom.sh;
    onChange = ''
      export PATH="$PATH:/run/current-system/sw/bin"
      export PATH="$PATH:/nix/var/nix/profiles/default/bin"
      export PATH="$PATH:/opt/homebrew/bin"
      export PATH="$PATH:/usr/local/bin"
      export PATH="$PATH:/usr/bin"

      EMACS_DIR="$HOME/.config/emacs"

      if [ ! -d "$EMACS_DIR" ]; then
        ${pkgs.git}/bin/git clone https://github.com/hlissner/doom-emacs.git $EMACS_DIR
        yes | $EMACS_DIR/bin/doom install
        $EMACS_DIR/bin/doom sync
      else
        $EMACS_DIR/bin/doom sync
      fi
      $EMACS_DIR/bin/doom env
    '';
  };

  # programs.doom-emacs = {
  #  enable = true;
  #  doomPrivateDir = ./doom.d;
  #  # emacsPackage = pkgs.emacs28;

  #   # Only init/packages so we only rebuild when those change.
  #   doomPackageDir = pkgs.linkFarm "doom-packages-dir" [
  #     {
  #       name = "init.el";
  #       path = ./doom.d/init.el;
  #     }
  #     {
  #       name = "packages.el";
  #       path = ./doom.d/packages.el;
  #     }
  #     {
  #       name = "config.el";
  #       path = pkgs.emptyFile;
  #     }
  #   ];

  #  extraConfig = ''
  #    (setq epg-gpg-program "${pkgs.gnupg}/bin/gpg")
  #  '';
  # };
}
