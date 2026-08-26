{
  inputs,
  outputs,
  config,
  pkgs,
  ...
}:

{
  users.users.albttx.shell = pkgs.zsh;
  # zsh must also be enabled system-side so it lands in /etc/shells.
  programs.zsh.enable = true;

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
    extraSpecialArgs = { inherit inputs outputs; };
    users.albttx = import ./hm-albttx.nix;
  };
}
