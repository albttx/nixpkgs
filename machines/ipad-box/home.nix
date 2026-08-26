{ config, pkgs, ... }:

let
  sshKeys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC6XZR1TQ/FAh502qM7IFm7XSqKr1sau6twvLhe+0jh/5IrJAm/D4eL44eq+td/4jq9ltYKGs0byFS+AbefQUfnQL5TBgYdsDAGyJ+H3OlAZu+6jLZKJXgfbmlluI5zCPoSeCJOakHrzLAhBFUz0c2N2HrLFee4wv9dgnJ9yURCFT/CXbGvFbDhhKPDBAusNW/45eguxr/Yrv0IRgUUMZxfaAMYFFCO081EUnyWV8bzncCqRVkM3LC/80Fn47YiANS5mVDKLnmymH4Q6kFzMz1ZX/igXrPgKhs73j9dIK/QDVQmkug2LJE7xW0w6uG3KFw4hQKMKxtrYlGV0tp5s44xN6CdWFbgHsyCKExm4VR+4ND/HOc9CuDWGxG4Rnlfeiv5HG9AGemcJZl3KbAOg3JL4xc3pN50CsrP9CxrORzkr9PBKWF/A1o/yWBGk2ZGr3oziTeY3Acy2rIlew4FS95R4+dNcLXIZ2inelFEFrQe83ZTGkN3Ey0G5G0fc/zRhX4DzXK1Kk6EPwUPSUCH50Sya9j6KXsOTxwI6USAB/MzXyoqL8MIgdJNd3T2lheAGZiUwAJOEjSF3tzo5llO2JQDkjV4K6atnvGsyUm54TzA9Ne7XBMgkmFIPveRCP7YVdGqgALvRI0C1loq6c8aIFcn7qmJrmlmLGfuXeLNBeCBrQ== albttx"
  ];
in
{
  # Root password. The hash lives in /etc/root-password-hash (mode 0600, on the
  # encrypted root) rather than inline, so it is not copied into /nix/store,
  # which is world-readable.
  users.users.root.hashedPasswordFile = "/etc/root-password-hash";

  users.users.root.openssh.authorizedKeys.keys = sshKeys;

  users.users.albttx = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = sshKeys;
  };

  # albttx has no password set (log in with the SSH key), so sudo cannot
  # prompt for one. Set one with `passwd albttx` and drop this if you prefer
  # password-protected sudo.
  security.sudo.wheelNeedsPassword = false;

  services.openssh.enable = true;
  services.openssh.settings = {
    # Log in as albttx (SSH key) and sudo; root stays usable on the console
    # and in the initrd remote-unlock sshd (port 2222), which is separate
    # from this one and keeps its own root key auth.
    PermitRootLogin = "no";
    PasswordAuthentication = true;
  };

  # Ban IPs that brute-force sshd (reads the journal, bans via the firewall).
  services.fail2ban = {
    enable = true;
    maxretry = 5;
    bantime = "1h";
    bantime-increment = {
      enable = true;
      maxtime = "48h";
    };
  };

  # `make switch.home-manager` runs plain `nix build` on the flake.
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  environment.systemPackages = with pkgs; [
    vim
    git
    gnumake # `make switch` from the dotfiles repo
  ];
}
