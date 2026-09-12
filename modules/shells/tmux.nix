{ pkgs, ... }:
let
  # gpakosz/.tmux default dark theme, carried over from the old
  # tmux.conf.local (colour_1..colour_17)
  colors = {
    bg = "#080808"; # dark gray
    bgAlt = "#303030"; # gray
    fgDim = "#8a8a8a"; # light gray
    blue = "#00afff";
    yellow = "#ffff00";
    white = "#e4e4e4";
    pink = "#ff00af";
    red = "#d70000";
  };
in
{
  programs.tmux = {
    enable = true;
    plugins = with pkgs.tmuxPlugins; [ tmux-fzf ];

    # keep the generated config self-contained instead of layering the
    # sensible plugin under it
    sensibleOnTop = false;

    terminal = "xterm-kitty";
    historyLimit = 10000;
    mouse = true;
    escapeTime = 10;
    focusEvents = true;
    baseIndex = 1;
    clock24 = true;

    # gpakosz derived vi mode from $EDITOR; make it explicit
    keyMode = "vi";
    # prefix h/j/k/l pane navigation, prefix H/J/K/L resize
    customPaneNavigationAndResize = true;
    resizeAmount = 2;

    extraConfig = ''
      # -- general -----------------------------------------------------------

      set -g prefix2 C-a            # GNU-Screen compatible prefix
      bind C-a send-prefix -2

      set -sg repeat-time 600
      set -g default-command "''${SHELL} -i"
      set -ga terminal-overrides ",xterm-kitty:Tc"

      # -- display -----------------------------------------------------------

      setw -g automatic-rename on   # rename window to reflect current program
      set -g renumber-windows on    # renumber windows when a window is closed

      set -g set-titles on
      set -g set-titles-string "#h ❐ #S ● #I #W"

      set -g display-panes-time 800
      set -g display-time 1000
      set -g status-interval 10

      # activity
      set -g monitor-activity on
      set -g visual-activity off

      # -- navigation --------------------------------------------------------

      bind C-c new-session
      bind C-f command-prompt -p "(find-session)" "switch-client -t %%"
      bind BTab switch-client -l    # move to last session

      # new panes retain current path, new windows do not
      bind - split-window -v -c "#{pane_current_path}"
      bind _ split-window -h -c "#{pane_current_path}"
      bind | split-window -h -c "#{pane_current_path}"

      bind > swap-pane -D
      bind < swap-pane -U
      bind + resize-pane -Z         # maximize/restore current pane

      # window navigation
      unbind n
      unbind p
      bind -r C-h previous-window
      bind -r C-l next-window
      bind Tab last-window
      bind 0 select-window -t :=10  # base-index is 1, so 0 targets window 10

      # toggle mouse
      bind m set -gF mouse "#{?mouse,off,on}" \; display "mouse: #{?mouse,on,off}"

      # -- copy mode ---------------------------------------------------------

      bind Enter copy-mode

      bind -T copy-mode-vi v send -X begin-selection
      bind -T copy-mode-vi C-v send -X rectangle-toggle
      bind -T copy-mode-vi y send -X copy-selection-and-cancel
      bind -T copy-mode-vi Escape send -X cancel
      bind -T copy-mode-vi H send -X start-of-line
      bind -T copy-mode-vi L send -X end-of-line

      # copying also reaches the OS clipboard (OSC 52, works over ssh)
      set -s set-clipboard on

      # -- buffers -----------------------------------------------------------

      bind b list-buffers
      bind p paste-buffer -p
      bind P choose-buffer

      # -- theme -------------------------------------------------------------

      set -g status-style "fg=${colors.fgDim},bg=${colors.bg}"
      set -g message-style "fg=${colors.bg},bg=${colors.yellow},bold"
      set -g message-command-style "fg=${colors.yellow},bg=${colors.bg},bold"
      setw -g mode-style "fg=${colors.bg},bg=${colors.yellow},bold"

      set -g pane-border-style "fg=${colors.bgAlt}"
      set -g pane-active-border-style "fg=${colors.blue}"
      set -g display-panes-colour "${colors.blue}"
      set -g display-panes-active-colour "${colors.blue}"
      set -g clock-mode-colour "${colors.blue}"

      setw -g window-status-style "fg=${colors.fgDim},bg=${colors.bg}"
      setw -g window-status-format " #I #W "
      setw -g window-status-current-style "fg=${colors.bg},bg=${colors.blue},bold"
      setw -g window-status-current-format " #I #W "
      setw -g window-status-last-style "fg=${colors.blue},bg=${colors.bgAlt}"
      setw -g window-status-activity-style "underscore"
      setw -g window-status-bell-style "fg=${colors.yellow},blink,bold"

      set -g status-left-length 100
      set -g status-right-length 150
      set -g status-left "#[fg=${colors.bg},bg=${colors.yellow},bold] ❐ #S #[default] "
      set -g status-right "#[fg=${colors.fgDim},bg=${colors.bg}] #{?client_prefix,⌨ ,}#{?mouse,↗ ,}#{?pane_synchronized,⚏ ,}| %R | %d %b #[fg=${colors.white},bg=${colors.red}] #(id -un) #[fg=${colors.bg},bg=${colors.white},bold] #h "
    '';
  };
}
