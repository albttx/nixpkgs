{
  description = "My Home Manager Flake";

  inputs = {
    nixpkgs-master.url = "github:nixos/nixpkgs/master";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixpkgs-24.05-darwin";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    # nix-doom-emacs = {
    #   url = "github:nix-community/nix-doom-emacs";
    #   inputs.nixpkgs.follows = "nixpkgs-unstable";
    #   inputs.emacs-overlay.follows = "emacs-overlay";
    # };

    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    flake-utils.url = "github:numtide/flake-utils";

    home-manager = {
      #url = "github:nix-community/home-manager/master";
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    catppuccin-kitty = {
      url = "github:catppuccin/kitty";
      flake = false;
    };

    awesome-git = {
      url = "github:awesomeWM/awesome";
      flake = false;
    };

    lain = {
      url = "github:lcpz/lain";
      flake = false;
    };

  };

  outputs =
    { self, nixpkgs, nix-darwin, home-manager, flake-utils, ... }@inputs:
    let
      inherit (self.lib) attrValues makeOverridable optionalAttrs singleton;
      inherit (self) outputs;

      homeStateVersion = "24.05";

      mkHome = modules: pkgs:
        home-manager.lib.homeManagerConfiguration {
          inherit modules pkgs;
          extraSpecialArgs = { inherit inputs outputs; };
        };

      # Configuration for `nixpkgs`
      nixpkgsDefaults = {
        config = { allowUnfree = true; };
        overlays = attrValues self.overlays ++ [
          # put stuff here
        ];
      };

    in {
      lib = inputs.nixpkgs-unstable.lib.extend (_: _: {
        mkDarwinSystem = import ./lib/mkDarwinSystem.nix inputs;
        lsnix = import ./lib/lsnix.nix;
      });

      overlays = {
        my-libvterm = import ./overlays/libvterm.nix;

        # Install master packages
        pkgs-master = _: prev: {
          pkgs-master = import inputs.nixpkgs-master {
            inherit (prev.stdenv) system;
            inherit (nixpkgsDefaults) config;
          };

          pkgs-stable = _: prev: {
            pkgs-stable = import inputs.nixpkgs-stable {
              inherit (prev.stdenv) system;
              inherit (nixpkgsDefaults) config;
            };
          };
          pkgs-unstable = _: prev: {
            pkgs-unstable = import inputs.nixpkgs-unstable {
              inherit (prev.stdenv) system;
              inherit (nixpkgsDefaults) config;
            };
          };

          # Overlay useful on Macs with Apple Silicon
          pkgs-silicon = _: prev:
            optionalAttrs (prev.stdenv.system == "aarch64-darwin") {
              # Add access to x86 packages system is running Apple Silicon
              pkgs-x86 = import inputs.nixpkgs-unstable {
                system = "x86_64-darwin";
                inherit (nixpkgsDefaults) config;
              };
            };

        };
      };

      darwinConfigurations = {
        # Mininal configurations to bootstrap systems
        bootstrap-x86 = nix-darwin.lib.darwinSystem {
          system = "x86_64-darwin";
          modules = [ ./darwin/bootstrap.nix { nixpkgs = nixpkgsDefaults; } ];
        };
        bootstrap-arm = nix-darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          modules = [ ./darwin/bootstrap.nix { nixpkgs = nixpkgsDefaults; } ];
        };

        mbp-albttx = nix-darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          specialArgs = { inherit inputs outputs; };
          modules = [
            ./machines/mbp-albttx/default.nix
            ./darwin/services/emacsd.nix
            home-manager.darwinModules.home-manager

            # ./modules/shells/tmux.nix
            { nixpkgs = { overlays = attrValues self.overlays ++ [ ]; }; }
            ({ inputs, config, pkgs, ... }: {
              imports = [
                # home-manager config
                ./machines/mbp-albttx/hm.nix
              ];
            })
          ];
        };
      };

      homeConfigurations = {
        "mbp-albttx" = mkHome [ ./machines/mbp-albttx/home.nix ]
          nixpkgs.legacyPackages."aarch64-darwin";
      };
    };
}
