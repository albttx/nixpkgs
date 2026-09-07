{ lib, pkgs, ... }:

let
  # ctrl+s picker. Lists every project (not just the ones with a live tmux
  # session) and hands the pick to `p add`, which clones if the checkout is
  # missing, creates the session if there isn't one, then attaches — or
  # switch-clients when $TMUX is set. So this script must not branch on tmux
  # itself; doing so would defeat that.
  fzf-p-projects = pkgs.writeShellScriptBin "fzf-p-projects" ''
    CODE_DIR="''${CODE_DIR:-$HOME/go/src}"

    # Exactly one tmux call. One `has-session` per project would be ~185
    # forks on every ^s and visibly laggy.
    sessions=$(${pkgs.tmux}/bin/tmux list-sessions -F '#{session_name}' 2>/dev/null || true)

    # `p list` emits host/owner/repo, but tmux sessions are named owner/repo,
    # so the host has to be stripped before the lookup. The full form is what
    # gets passed on to `p add` below.
    selected=$(
      ${pkgs.p}/bin/p list --code-dir "$CODE_DIR" \
        | ${pkgs.gawk}/bin/awk -v sessions="$sessions" '
            BEGIN {
              n = split(sessions, s, "\n")
              for (i = 1; i <= n; i++)
                if (s[i] != "") running[s[i]] = 1
            }
            {
              short = $0
              sub(/^[^\/]+\//, "", short)
              if (short in running) print "0\t● " $0
              else                  print "1\t  " $0
            }
          ' \
        | LC_ALL=C ${pkgs.coreutils}/bin/sort -f \
        | ${pkgs.coreutils}/bin/cut -f2- \
        | ${pkgs.fzf}/bin/fzf \
            --prompt 'project> ' \
            --layout=reverse \
            --no-sort
    ) || exit 0

    # Esc / ^c: fzf exits non-zero with no output. Never call `p add ""`.
    [ -n "$selected" ] || exit 0

    # Drop the running marker, restoring the exact host/owner/repo. Two
    # projects live on gitlab.com, so letting `p add` default the host to
    # github.com would silently pick the wrong repo.
    selected=''${selected#● }
    selected=''${selected#  }

    exec ${pkgs.p}/bin/p add --code-dir "$CODE_DIR" "$selected"
  '';
in
{
  home.packages = [
    pkgs.fd
    fzf-p-projects
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
        ${fzf-p-projects}/bin/fzf-p-projects
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
