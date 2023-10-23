{ config, lib, pkgs, ... }:
let
  #theme = import ../../../themes/catppuccin/mocha.nix;
  #theme = import ../../../themes/solarized.nix;
  #theme = config.colors.catppuccin-mocha;
  #theme = config.colors.catppuccin-macchiato;
  #theme = config.colors.solarized-dark;
  #theme = config.colors.catppuccin-mocha;
in {
  # Better terminal, with good rendering.
  programs.kitty = {
    enable = true;
    # Pick "name" from https://github.com/kovidgoyal/kitty-themes/blob/master/themes.json
    # theme = "Tokyo Night";
    theme = "Catppuccin-Mocha";

    extraConfig = ''

    '';

    keybindings = {
      "ctrl+shift+up"    = "no_op";
      "ctrl+shift+down"  = "no_op";
      "ctrl+shift+left"  = "no_op";
      "ctrl+shift+right" = "no_op";

      "super+/" = "no_op";

      "super+up" = "no_op";
      "super+down" = "no_op";
      "super+left" = "no_op";
      "super+right" = "no_op";
    };

    #font = {
    #  name = "Monaco";
    #  size = 14;
    #};
    #keybindings = {
    #  "kitty_mod+e" = "kitten hints"; # https://sw.kovidgoyal.net/kitty/kittens/hints/
    #};
    settings = {
      # https://github.com/kovidgoyal/kitty/issues/371#issuecomment-1095268494
      # mouse_map = "left click ungrabbed no-op";
      # Ctrl+Shift+click to open URL.
      confirm_os_window_close = "0";
      # https://github.com/kovidgoyal/kitty/issues/847
      macos_option_as_alt = "yes";

      tab_bar_style = "powerline";
      tab_title_template = "{index}: {title}";
      active_tab_font_style = "bold";
      inactive_tab_font_style = "normal";
    };
  };
}
