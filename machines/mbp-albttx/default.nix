{ config, pkgs, lib, home-manager, ... }:
let
  #secrets = import ../../secrets.nix;
in {
  imports = [
    ../common/darwin/defaults.nix
    ./homebrew.nix

    ../../darwin/bootstrap.nix

    # ../../darwin/services/emacsd.nix
    #../../modules/emacs/doom-emacs.nix
  ];

  programs.nix-index.enable = true;
  # Apps
  # `home-manager` currently has issues adding them to `~/Applications`
  # Issue: https://github.com/nix-community/home-manager/issues/1341
  environment.systemPackages = with pkgs; [ kitty terminal-notifier ];

  # Use a custom configuration.nix location.
  # $ darwin-rebuild switch -I darwin-config=$HOME/.config/nixpkgs/darwin/configuration.nix
  environment.darwinConfig =
    "$HOME/go/src/github.com/albttx/nixpkgs/machines/mbp-albttx/default.nix";

  ids.gids.nixbld = 350; # [hack]

  #environment.variables.SSH_AUTH_SOCK = "/Users/albttx/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock";

  # security.pki.certificateFiles = [ secrets.work_certpath ];

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;

  system = {
    primaryUser = "albttx";

    defaults = {
      dock = {
        autohide = true;
        autohide-delay = 0.0;
        orientation = "left";
      };

      CustomUserPreferences = {
        "com.apple.mail" = {
          InboxViewerAttributes = {
            # DisplayInThreadedMode = "yes";
            # DisableInlineAttachmentViewing = true;
            # SortedDescending = "yes";
            # SortOrder = "received-date";
          };
          NSUserKeyEquivalents = {
            # Send = "@U21a9"; # cmd + enter
            Archive = "\\U007F"; # delete
          };
        };
      };

    };
  };
}
