{ config, pkgs, lib, home-manager, ... }:
let
  #secrets = import ../../secrets.nix;
in {
  imports = [
    ../common/darwin/defaults.nix
    ./homebrew.nix

    ../../darwin/bootstrap.nix
    ../../darwin/services/emacsd.nix

    #../../modules/emacs/doom-emacs.nix
  ];

  # Apps
  # `home-manager` currently has issues adding them to `~/Applications`
  # Issue: https://github.com/nix-community/home-manager/issues/1341
  environment.systemPackages = with pkgs; [ emacs-gtk kitty terminal-notifier ];

  #services.emacsd = {
  #  package = pkgs.emacs-gtk;
  #  enable = true;
  #};

  fonts.fontDir.enable = false;
  fonts.fonts = with pkgs; [
    # recursive
    emacs-all-the-icons-fonts
    (nerdfonts.override { fonts = [ "Iosevka" "JetBrainsMono" "FiraCode" ]; })
  ];

  # Use a custom configuration.nix location.
  # $ darwin-rebuild switch -I darwin-config=$HOME/.config/nixpkgs/darwin/configuration.nix
  environment.darwinConfig =
    "$HOME/go/src/github.com/albttx/nixpkgs/machines/mbp-albttx/default.nix";

  #environment.variables.SSH_AUTH_SOCK = "/Users/albttx/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock";

  # security.pki.certificateFiles = [ secrets.work_certpath ];

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;
}
