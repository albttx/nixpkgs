{ inputs, config, lib, pkgs, nixos, system, ... }:

{
  nixpkgs.overlays = [ inputs.emacs-overlay.overlay ];

  home.packages = with pkgs; [
    # basics
    fd
    git
    # build tools
    clang
    coreutils

    #completion tools
    #ripgrep
    (ripgrep.override {withPCRE2 = true;})

    # :lang nix
    nixfmt

    # :lang javascript
    nodejs
    nodePackages.npm
    nodePackages.prettier
    bun

    ## lsp
    nodePackages.typescript-language-server



    # syntax color
    emacs-all-the-icons-fonts
  ];

  #home = {
  #  ".doom.d/init.el".source = ./doom.d/init.el;
  #  ".doom.d/config.el".source = ./doom.d/config.el;
  #  ".doom.d/packages.el".source = ./doom.d/packages.el;
  #};


  programs.doom-emacs = {
    enable = true;
    doomPrivateDir = ./doom.d;
    #	extraConfig = ''
    #	  (setq epg-gpg-program "${pkgs.gnupg}/bin/gpg")
    #	'';
  };
}
