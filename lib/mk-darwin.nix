{ inputs, overlays }:

{ system, username }:

inputs.darwin.lib.darwinSystem {
  inherit system;

  modules = [
    #../users/${username}/darwin.nix
    ../machines/mbp-albttx/default.nix
    inputs.home-manager.darwinModules.home-manager
    inputs.nix-homebrew.darwinModules.nix-homebrew
    {
      nixpkgs = {
        config = {
          allowUnfree = true;
        };
        overlays = overlays;
      };

      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.users.${username} = import ../users/${username}/home-manager.nix;

      nix-homebrew = {
        enable = true;
        enableRosetta = true;
        user = "${username}";
        # autoMigrate = true;
      };
    }
  ];
}
