{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    oh-my-zsh
    eza

    (writeScriptBin "fzf-tmux-sessions" ''
      #!/bin/sh
      selected_session=$(tmux list-sessions -F "#{session_name}" | fzf)

      if [ -n "$selected_session" ]; then
          tmux switch-client -t "$selected_session"
      fi
    '')
  ];

  programs = {
    zsh = {
      enable = true;
      enableCompletion = false;
      dotDir = ".config/zsh";

      oh-my-zsh = {
        enable = true;
        plugins = [ "git" "sudo" "docker" ];
      };

      shellAliases = {
        icat = "kitten icat";

        ls = "eza";
        #TODO: add mkIf isLinux
        # pbcopy = "xclip -selection clipboard";
        # pbpaste = "xclip -selection clipboard -o";

        "docker-compose" = "docker compose";

        dckdel = "docker rm -f $(docker ps -aq)";
        fcd = "cd $(fd --type directory | fzf)";
      };

      initExtra = ''
        mcd() { mkdir -p "$1" && cd "$1"; }
      '';

      initContent = let p10k-config = "${config.home.homeDirectory}/.p10k.zsh";
      in ''
        if [ -e "${p10k-config}" ]
        then
          source "${p10k-config}"
        fi

        # source profileExtra
        source ${config.home.homeDirectory}/.config/zsh/.zprofile
      '';

      profileExtra = ''
        if [ -f "${config.home.profileDirectory}/etc/profile.d/nix.sh" ]; then
          source "${config.home.profileDirectory}/etc/profile.d/nix.sh"
        fi

        fzf_tmux_sessions_widget() fzf-tmux-sessions
        zle -N fzf_tmux_sessions_widget
        bindkey '^s' fzf_tmux_sessions_widget

        bindkey '^[[1;5D' backward-word
        bindkey '^[[1;5C' forward-word
        bindkey '^H' backward-delete-char 
        bindkey  "^[[H"   beginning-of-line
        bindkey  "^[[F"   end-of-line

        bindkey '^[[A' up-line-or-search
        bindkey '^[[B' down-line-or-search


        #_HM_SESS_VARS_SOURCED= . $HOME/.nix-profile/etc/profile.d/hm-session-vars.sh
      '';

      plugins = [
        {
          name = "powerline10k";
          src = pkgs.zsh-powerlevel10k;
          file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
        }

        {
          name = "autosuggestions";
          src = pkgs.zsh-autosuggestions;
          file = "share/zsh-autosuggestions/zsh-autosuggestions.zsh";
        }

        {
          name = "fast-syntax-highlighting";
          src = pkgs.zsh-fast-syntax-highlighting;
          file = "share/zsh/site-functions/fast-syntax-highlighting.plugin.zsh";
        }
      ];
    };

    direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };
  };

  home.file.".p10k.zsh".source = ./configs/p10k.zsh;
}
