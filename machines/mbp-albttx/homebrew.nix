{ config, pkgs, ... }:

{
  #homebrew packages
  homebrew = {
    enable = true;

    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "zap";
    };

    brews = [
      # brew install cask
      "cask"

      "libvterm"
      "libtool"

      "supabase/tap/supabase"
    ];

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
      "charles"
      "cursor"
      "discord"
      "docker"
      # "flameshot" # screenshot
      "keybase"
      "emacs"

      "ghostty"

      "ledger-live"
      # "libiconv" # lib required for rust

      "notion"
      "orbstack"
      "protonvpn"
      "raycast"
      "rectangle"
      "slack"
      "signal"
      "spotify"
      "superhuman"

      # Usage:
      #  https://github.com/tailscale/tailscale/wiki/Tailscaled-on-macOS#run-the-tailscaled-daemon
      # 1. `sudo tailscaled install-system-daemon`
      # 2. `tailscale up --accept-routes`
      "tailscale"
      "telegram"

      # zed code editor
      # TODO: install via nix, currently it's broken
      "zed"
    ];

    masApps = {
      #"1Password for Safari" = 1569813296;
      #DaisyDisk = 411643860;
      Numbers = 409203825;
      Pages = 409201541;
      Xcode = 497799835;
      Perplexity = 6714467650;
      WhatsApp = 310633997;
      Todoist = 585829637;
    };
  };
}
