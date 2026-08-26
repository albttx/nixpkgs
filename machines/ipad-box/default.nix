{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./networking.nix
    ./home.nix
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

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "26.05"; # Did you read the comment?
}
