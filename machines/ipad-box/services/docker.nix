{ pkgs, ... }:

{
  # Docker is the runtime for oci-containers on this host. The module default
  # is podman once stateVersion >= 22.05; pin Docker explicitly so future
  # services inherit the same backend.
  virtualisation.docker = {
    enable = true;
    autoPrune.enable = true;
  };
  virtualisation.oci-containers.backend = "docker";

  environment.systemPackages = [ pkgs.docker-compose ];

  # So `docker` / `docker compose` work as albttx without sudo.
  users.users.albttx.extraGroups = [ "docker" ];
}
