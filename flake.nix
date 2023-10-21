{
    description = "My Home Manager Flake";

    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
        nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-23.05";
        nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
        nixpkgs-master.url = "github:nixos/nixpkgs";

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

    outputs = inputs@{nixpkgs, home-manager, ...}: {
        #defaultPackage.x86_64-linux = home-manager.defaultPackage.x86_64-linux;
        #defaultPackage.x86_64-darwin = home-manager.defaultPackage.x86_64-darwin;

        # specialArgs = { inherit inputs; };

        overlays = import ./overlays { inherit inputs; };

        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;

        homeConfigurations = {
            "mac" = home-manager.lib.homeManagerConfiguration {
                # Note: I am sure this could be done better with flake-utils or something
                # pkgs = nixpkgs.legacyPackages.x86_64-linux;
                pkgs = nixpkgs.legacyPackages.aarch64-darwin;
                
                # pkgs = import nixpkgs {
                #     inherit inputs;
                # };

                extraSpecialArgs = {
                  inherit inputs nixpkgs;
                };

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

                extraSpecialArgs = {
                  inherit inputs nixpkgs;
                };

                modules = [ ./thinkpad-p1.nix ];
            };

            "surface" = home-manager.lib.homeManagerConfiguration {
                # Note: I am sure this could be done better with flake-utils or something
                # pkgs = nixpkgs.legacyPackages.x86_64-linux;
                pkgs = nixpkgs.legacyPackages.x86_64-linux;
                
                # pkgs = import nixpkgs {
                #     inherit inputs;
                # };

                extraSpecialArgs = {
                  inherit inputs nixpkgs;
                };

                modules = [ ./surface.nix ];
            };

        };
    };
}
