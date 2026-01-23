{ inputs, config, lib, pkgs, nixos, system, ... }:

{
  # nixpkgs.overlays = [ inputs.emacs-overlay.overlay ];

  home.packages = with pkgs; [
    sqlite # required by magit

    # basics
    fd
    git
    # nerdfonts
    fontconfig

    # build tools
    clang
    cmake
    libtool
    coreutils
    # libvterm # installed with overlay my-libvterm

    #completion tools
    semgrep
    ripgrep
    silver-searcher

    # :searcher nix
    nixfmt-classic

    # :lang javascript
    nodejs
    nodePackages.npm
    nodePackages.prettier
    nodePackages.typescript-language-server

    # TODO: install editor config
    #nodePackages.editorconfig
    bun

    # :checkers
    aspell

    # :tools
    # dockfmt
    # editorconfig

    # :lang org
    pngpaste
    graphviz

    # :lang python
    black
    python312Packages.pyflakes
    # python312Packages.pynose
    python312Packages.pytest
    isort
    # pipenv

    # :lang markdown
    ispell
    gh-markdown-preview

    # :lang go
    golangci-lint-langserver

    # :lang bash
    shellcheck
    shfmt

    # :lang web
    # stylelint
    jsbeautifier

    ## lsp
    # (pkgs.buildGoModule {
    #   pname = "gnopls";
    #   version = "v0.1.0";
    #   src = pkgs.fetchFromGitHub {
    #     owner = "gnolang";
    #     repo = "gnopls";
    #     rev = "v0.1.0";
    #     sha256 = "sha256-3LWeWIDn8+IMrXZGSJwx/9BKFoBx4puPcRFDIVq4Yiw=";
    #   };
    #   lsFlags = [ "-mod=mod" ];
    #   vendorHash = "sha256-xaIv3l+7kNlywtiCg7YvP+WMVOilzCLvyOA9gGeUziQ=";
    # })

    # syntax color
    emacs-all-the-icons-fonts
  ];

  programs.zsh.initContent = ''
    export PATH="$HOME/.config/emacs/bin:$PATH"
  '';

  programs.zsh.shellAliases = {
    # emacs cli
    # e = "emacsclient --tty";
    e = "$HOME/.config/emacs/bin/doom emacs";
  };

  home.file.".doom.d" = {
    source = ./doom.d;
    recursive = true;
    #onChange = builtins.readFile ./doom.sh;
    onChange = ''
      export PATH="$PATH:/usr/bin"
      export PATH="$PATH:/usr/local/bin"
      export PATH="$PATH:/opt/homebrew/bin"
      export PATH="$PATH:$HOME/go/bin"
      export PATH="$PATH:$HOME/.config/emacs/bin"
      export PATH="$PATH:/run/current-system/sw/bin"
      export PATH="$PATH:/nix/var/nix/profiles/default/bin"
      export PATH="$PATH:/etc/profiles/per-user/albttx/bin/"


      EMACS_DIR="$HOME/.config/emacs"
      mkdir -p $HOME/.config

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
