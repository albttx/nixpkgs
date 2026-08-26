{ config, pkgs, ... }:

{
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
}
