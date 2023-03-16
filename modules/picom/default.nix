{ config, lib, pkgs, ... }:
{
  services.picom = {
    enable = true;
    extraArgs = [ "--legacy-backends" ];
    shadow = true;
    shadowExclude = [
      "window_type *= 'menu'"
      "name ~= 'Firefox\$'"
      "focused = 1"
      "n:e:Notification"
      "n:e:Docky"
      "g:e:Synapse"
      "g:e:Conky"
      "n:w:*Firefox*"
      "n:w:*Chromium*"
      "n:w:*dockbarx*"
      "class_g ?= 'Cairo-dock'"
      "class_g ?= 'Xfce4-panel'"
      "class_g ?= 'Xfce4-notifyd'"
      "class_g ?= 'Xfce4-power-manager'"
      "class_g ?= 'Notify-osd'"
      "_GTK_FRAME_EXTENTS@:c"
    ];

    fade = true;
    fadeDelta = 3;
    shadowOpacity = 0.3;
    settings = {
      corner-radius = 10;
      shadow-radius = 20;
    };
  };

  systemd.user.services.picom.Install.WantedBy = lib.mkForce [ "x11-session.target" ];
}
