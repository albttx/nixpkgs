{
  inputs,
  outputs,
  config,
  pkgs,
  lib,
  ...
}:

{
  users.users.albttx.shell = pkgs.zsh;
  # zsh must also be enabled system-side so it lands in /etc/shells.
  programs.zsh.enable = true;

  # The doom.d onChange hook clones and byte-compiles all Doom Emacs packages
  # on first run, which blows through the default start timeout — systemd then
  # kills the activation mid-sync and leaves Doom broken.
  systemd.services.home-manager-albttx.serviceConfig.TimeoutStartSec = lib.mkForce "1h";

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
    extraSpecialArgs = { inherit inputs outputs; };
    users.albttx = import ./hm-albttx.nix;
  };
}
