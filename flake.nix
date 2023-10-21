{
  description = "My Home Manager Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-23.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-master.url = "github:nixos/nixpkgs";

    darwin.url = "github:lnl7/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs-unstable";

    flake-utils.url = "github:numtide/flake-utils";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    awesome-git = {
      url = "github:awesomeWM/awesome";
      flake = false;
    };

    lain = {
      url = "github:lcpz/lain";
      flake = false;
    };

    tmux-conf = {
      url = "github:gpakosz/.tmux";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, darwin, home-manager, flake-utils, ... }@inputs:
    let
      inherit (self.lib) attrValues makeOverridable optionalAttrs singleton;

      homeStateVersion = "23.05";

      # Configuration for `nixpkgs`
      nixpkgsDefaults = {
        config = { allowUnfree = true; };
        overlays = attrValues self.overlays ++ [
          # put stuff here
        ];
      };

      primaryUserInfo = {
        username = "albttx";
        fullName = "";
        email = "contact@albttx.tech";
        nixConfigDirectory = "/Users/albttx/go/src/github.com/albttx/nixpkgs";
      };

      ciUserInfo = {
        username = "runner";
        fullName = "";
        email = "github-actions@github.com";
        nixConfigDirectory = "/Users/runner/work/nixpkgs/nixpkgs";
      };

    in {
      inherit (darwin.lib) darwinSystem;
      #defaultPackage.x86_64-linux = home-manager.defaultPackage.x86_64-linux;
      #defaultPackage.x86_64-darwin = home-manager.defaultPackage.x86_64-darwin;

      lib = inputs.nixpkgs-unstable.lib.extend (_: _: {
        mkDarwinSystem = import ./lib/mkDarwinSystem.nix inputs;
        lsnix = import ./lib/lsnix.nix;
      });

      commonModules = {
        #colors = import ./modules/home/colors;
        #my-colors = import ./home/colors.nix;
      };

      darwinModules = {
        # My configurations
        my-bootstrap = import ./darwin/bootstrap.nix;
        #my-defaults = import ./darwin/defaults.nix;
        #my-env = import ./darwin/env.nix;
        #my-homebrew = import ./darwin/homebrew.nix;
        #my-yabai = import ./darwin/yabai.nix;
        #my-skhd = import ./darwin/skhd.nix;

        # local modules
        #services-emacsd = import ./modules/darwin/services/emacsd.nix;
        users-primaryUser = import ./modules/darwin/users.nix;
        #programs-nix-index = import ./modules/darwin/programs/nix-index.nix;
      };


      # specialArgs = { inherit inputs; };

      overlays = import ./overlays { inherit inputs; };

      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;

      darwinConfigurations = rec {
        # Mininal configurations to bootstrap systems
        bootstrap-x86 = makeOverridable darwin.lib.darwinSystem {
          system = "x86_64-darwin";
          modules = [ ./darwin/bootstrap.nix { nixpkgs = nixpkgsDefaults; } ];
        };
        bootstrap-arm = bootstrap-x86.override { system = "aarch64-darwin"; };

        # My Apple Silicon macOS laptop config
        macbook = makeOverridable self.lib.mkDarwinSystem (primaryUserInfo // {
          system = "aarch64-darwin";
          modules = (attrValues self.darwinModules)
            ++ (attrValues self.commonModules) ++ singleton {
              nixpkgs = nixpkgsDefaults;
              networking.computerName = "guicp";
              networking.hostName = "ghost";
              networking.knownNetworkServices =
                [ "Wi-Fi" "USB 10/100/1000 LAN" ];
              nix.registry.my.flake = inputs.self;
            };

          inherit homeStateVersion;
          homeModules = (attrValues self.homeManagerModules)
            ++ (attrValues self.commonModules) ++ [

            ];
        });
      };

      homeConfigurations = {
        "mbp-wolf" = home-manager.lib.homeManagerConfiguration {
          # Note: I am sure this could be done better with flake-utils or something
          # pkgs = nixpkgs.legacyPackages.x86_64-linux;
          pkgs = nixpkgs.legacyPackages.aarch64-darwin;

          extraSpecialArgs = { inherit inputs nixpkgs; };

          modules = [ ./macos.nix ];
        };

        # thinkpad-p1
        "thinkpad" = home-manager.lib.homeManagerConfiguration {
          # Note: I am sure this could be done better with flake-utils or something
          # pkgs = nixpkgs.legacyPackages.x86_64-linux;
          pkgs = nixpkgs.legacyPackages.x86_64-linux;

          # pkgs = import nixpkgs {
          #     inherit inputs;
          # };

          extraSpecialArgs = { inherit inputs nixpkgs; };

          modules = [ ./thinkpad-p1.nix ];
        };

        "surface" = home-manager.lib.homeManagerConfiguration {
          # Note: I am sure this could be done better with flake-utils or something
          # pkgs = nixpkgs.legacyPackages.x86_64-linux;
          pkgs = nixpkgs.legacyPackages.x86_64-linux;

          # pkgs = import nixpkgs {
          #     inherit inputs;
          # };

          extraSpecialArgs = { inherit inputs nixpkgs; };

          modules = [ ./surface.nix ];
        };

      };
    };
}
