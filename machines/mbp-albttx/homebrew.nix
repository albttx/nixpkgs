{ config, pkgs, ... }:

{
  #homebrew packages
  homebrew = {
    enable = true;
    onActivation.autoUpdate = true;
    onActivation.upgrade = true;
    onActivation.cleanup = "zap";
    brews = [ "cask" ];
    taps = [ "homebrew/bundle" "homebrew/cask-fonts" "homebrew/services" ];
    casks = [
      # Fonts
      "font-fira-mono-nerd-font"
      "font-fira-code-nerd-font"
      "font-jetbrains-mono-nerd-font"

      # Applications
      "1password"
      "1password-cli" # need to install CLI via brew too to make biometric unlock work with GUI app
      "arc"
      "discord"
      # "flameshot" # screenshot
      "protonvpn"
      "raycast"
      "slack"
      "tailscale"
      "signal"
      "spotify"
      "superhuman"
    ];

    masApps = {
      #"1Password for Safari" = 1569813296;
      #DaisyDisk = 411643860;
      Numbers = 409203825;
      Pages = 409201541;
      Xcode = 497799835;
    };
  };
}
