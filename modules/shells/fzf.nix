{ lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    fd

    # ctrl+s picker. `p list` emits host/owner/repo, which is exactly what
    # `p add` accepts, so the fzf selection is passed straight through.
    # `p add` clones if the checkout is missing, creates the tmux session if
    # there isn't one, then attaches — or switch-clients when $TMUX is set.
    (writeShellScriptBin "fzf-p-projects" ''
      selected=$(p list | fzf --prompt 'project> ' --layout=reverse)

      # Esc / ^c: fzf exits non-zero with no output. Never call `p add ""`.
      if [ -n "$selected" ]; then
        exec p add "$selected"
      fi
    '')
  ];

  programs.zsh = {
    plugins = [
      {
        name = "fzf-marks";
        file = "fzf-marks.plugin.zsh";
        src = pkgs.fetchFromGitHub {
          owner = "urbainvaes";
          repo = "fzf-marks";
          rev = "f2e8844ce813f8ad35a1903eb8c680c4492e153b";
          sha256 = "0a8jlwc12m0xid2v4d7rxzci91w8qrc4x91jq4lv0lm62v2w4n1j";
        };
      }
    ];

    # mkAfter so the binding lands after the plugins and after zsh.nix sources
    # .zprofile, which is where ^s used to be bound.
    initContent = lib.mkAfter ''
      fzf-p-projects-widget() {
        fzf-p-projects
        local ret=$?
        zle reset-prompt
        return $ret
      }
      zle -N fzf-p-projects-widget
      bindkey '^s' fzf-p-projects-widget
    '';
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    defaultCommand = "fd --type f";
    defaultOptions = [
      "--height"
      "40%"
      "--border"
    ];
    fileWidgetCommand = "fd --type f";
    fileWidgetOptions = [
      "--preview"
      "'file {}; head {}'"
    ];
    changeDirWidgetCommand = "fd --type d";
    changeDirWidgetOptions = [
      "--preview"
      "'tree -C {} | head -200'"
    ];
    historyWidgetOptions = [
      "--sort"
      "--exact"
    ];

    tmux.enableShellIntegration = false;
  };

  home.sessionVariables = {
    # FZF_TMUX = "1";
    # FZF_TMUX_HEIGHT = "30%";
    # for times the escape needed, because \ is not escaped! when pasting
    # into the bash file
    FZF_COMPLETION_TRIGGER = "\\\\";
  };

  home.activation.generateFzFMarks = lib.hm.dag.entryAfter [ "installPackages" ] ''
    CODE_DIR="$HOME/go/src"

    ${pkgs.p}/bin/p list --code-dir "$CODE_DIR" | sort --ignore-case | while read -r proj; do
      echo "''${proj#*/} : $CODE_DIR/$proj"
    done > $HOME/.fzf-marks
  '';
}
