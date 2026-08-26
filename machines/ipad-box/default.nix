{ config, pkgs, ... }:

let
  sshKeys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC6XZR1TQ/FAh502qM7IFm7XSqKr1sau6twvLhe+0jh/5IrJAm/D4eL44eq+td/4jq9ltYKGs0byFS+AbefQUfnQL5TBgYdsDAGyJ+H3OlAZu+6jLZKJXgfbmlluI5zCPoSeCJOakHrzLAhBFUz0c2N2HrLFee4wv9dgnJ9yURCFT/CXbGvFbDhhKPDBAusNW/45eguxr/Yrv0IRgUUMZxfaAMYFFCO081EUnyWV8bzncCqRVkM3LC/80Fn47YiANS5mVDKLnmymH4Q6kFzMz1ZX/igXrPgKhs73j9dIK/QDVQmkug2LJE7xW0w6uG3KFw4hQKMKxtrYlGV0tp5s44xN6CdWFbgHsyCKExm4VR+4ND/HOc9CuDWGxG4Rnlfeiv5HG9AGemcJZl3KbAOg3JL4xc3pN50CsrP9CxrORzkr9PBKWF/A1o/yWBGk2ZGr3oziTeY3Acy2rIlew4FS95R4+dNcLXIZ2inelFEFrQe83ZTGkN3Ey0G5G0fc/zRhX4DzXK1Kk6EPwUPSUCH50Sya9j6KXsOTxwI6USAB/MzXyoqL8MIgdJNd3T2lheAGZiUwAJOEjSF3tzo5llO2JQDkjV4K6atnvGsyUm54TzA9Ne7XBMgkmFIPveRCP7YVdGqgALvRI0C1loq6c8aIFcn7qmJrmlmLGfuXeLNBeCBrQ== albttx"
  ];
in
{
  imports = [
    ./hardware-configuration.nix
  ];

  # Hetzner uses legacy BIOS boot, so GRUB2, not systemd-boot.
  # Installed to both disks so the machine still boots if one dies.
  boot.loader.systemd-boot.enable = false;
  boot.loader.grub = {
    enable = true;
    efiSupport = false;
    devices = [ "/dev/sda" "/dev/sdb" ];
  };

  boot.swraid.enable = true;
  # The RAIDs were created with 'mdadm --create ... --homehost=hetzner'.
  # mdadm's HOMEHOST defaults to the system hostname, and considers arrays from
  # a different homehost "foreign", exposing them as '/dev/md/hetzner:root0'
  # instead of '/dev/md/root0'. We never move these disks between machines, so
  # ignore homehost entirely and keep the names stable.
  boot.swraid.mdadmConf = ''
    HOMEHOST <ignore>
    MAILADDR root
  '';

  # Encrypted root: /dev/md1 -> LUKS -> LVM (vg0) -> ext4.
  # /boot is a separate unencrypted ext4 on /dev/md0, because GRUB cannot
  # unlock a LUKS2/argon2id container.
  boot.initrd.luks.devices."cryptroot" = {
    device = "/dev/disk/by-uuid/fa7c72f1-a3ef-4e52-9556-b0935a2d0d8c";
    allowDiscards = true; # TRIM through to the SSDs
  };

  boot.initrd.availableKernelModules = [ "raid1" "dm_mod" "dm_crypt" ];
  # NIC driver must be in the initrd for the remote-unlock SSH server below.
  boot.initrd.kernelModules = [ "e1000e" ];

  # ---- Remote unlock ----
  # On boot the machine stops in the initrd waiting for the LUKS passphrase.
  # Log in with:   ssh -p 2222 root@138.201.59.13
  # then run:      systemd-tty-ask-password-agent
  # enter the passphrase, and the boot continues.
  boot.initrd.network.enable = true;
  boot.initrd.systemd.network.enable = true;
  boot.initrd.systemd.network.networks."10-wan" = {
    matchConfig.Name = "enp0s31f6";
    address = [ "138.201.59.13/26" ];
    gateway = [ "138.201.59.1" ];
  };

  # Without this, systemd gives up waiting for the root device (LVM on LUKS)
  # after 90s and drops to emergency mode if the passphrase hasn't been
  # entered yet. Wait forever instead: the passphrase may arrive over SSH
  # minutes after boot.
  boot.initrd.systemd.settings.Manager.DefaultDeviceTimeoutSec = "infinity";

  boot.initrd.network.ssh = {
    enable = true;
    port = 2222;
    # authorizedKeys defaults to users.users.root.openssh.authorizedKeys.keys,
    # i.e. the same keys as the booted system.
    hostKeys = [ "/etc/secrets/initrd/ssh_host_ed25519_key" ];
  };

  networking.hostName = "ipad-box";

  # Hetzner uses static IP assignments; no DHCP.
  networking.useDHCP = false;
  networking.interfaces."enp0s31f6".ipv4.addresses = [
    {
      address = "138.201.59.13";
      # Hetzner requires /32, see:
      #   https://docs.hetzner.com/robot/dedicated-server/network/net-config-debian-ubuntu/#ipv4
      # NixOS sets up the gateway route because defaultGateway.interface is set.
      prefixLength = 32;
    }
  ];
  networking.interfaces."enp0s31f6".ipv6.addresses = [
    {
      address = "2a01:4f8:172:1407::1";
      prefixLength = 64;
    }
  ];
  networking.defaultGateway = {
    address = "138.201.59.1";
    interface = "enp0s31f6";
  };
  networking.defaultGateway6 = { address = "fe80::1"; interface = "enp0s31f6"; };
  networking.nameservers = [ "8.8.8.8" "1.1.1.1" ];

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
    # Root may log in with the SSH key above or with the root password.
    PermitRootLogin = "yes";
    PasswordAuthentication = true;
  };

  environment.systemPackages = with pkgs; [ vim git ];

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "26.05"; # Did you read the comment?
}
