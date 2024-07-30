{ lib, pkgs, ... }:

{
  home.packages = [ pkgs.fd ];

  programs.zsh = {
    plugins = [{
      name = "fzf-marks";
      file = "fzf-marks.plugin.zsh";
      src = pkgs.fetchFromGitHub {
        owner = "urbainvaes";
        repo = "fzf-marks";
        rev = "f2e8844ce813f8ad35a1903eb8c680c4492e153b";
        sha256 = "0a8jlwc12m0xid2v4d7rxzci91w8qrc4x91jq4lv0lm62v2w4n1j";
      };
    }];
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    defaultCommand = "fd --type f";
    defaultOptions = [ "--height" "40%" "--border" ];
    fileWidgetCommand = "fd --type f";
    fileWidgetOptions = [ "--preview" "'file {}; head {}'" ];
    changeDirWidgetCommand = "fd --type d";
    changeDirWidgetOptions = [ "--preview" "'tree -C {} | head -200'" ];
    historyWidgetOptions = [ "--sort" "--exact" ];

    tmux.enableShellIntegration = false;
  };

  home.sessionVariables = {
    # FZF_TMUX = "1";
    # FZF_TMUX_HEIGHT = "30%";
    # for times the escape needed, because \ is not escaped! when pasting
    # into the bash file
    FZF_COMPLETION_TRIGGER = "\\\\";
  };

  home.activation.generateFzFMarks =
    lib.hm.dag.entryAfter [ "installPackages" ] ''
      #!/usr/bin/env bash

      DIRS=$(find $HOME/go/src -name .git -type d -prune | sort --ignore-case)

      echo -n "" > $HOME/.fzf-marks

      for d in $DIRS; do
          d=$(echo $d | sed 's/\/.git//g')
          name=$(echo $d | sed -E "s/^.*(github\.com|gitlab\.com)\///g")
          echo "$name : $d" >> $HOME/.fzf-marks
      done
    '';
}
