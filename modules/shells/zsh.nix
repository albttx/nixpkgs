{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    oh-my-zsh
    eza
  ];

  programs = {
    zsh = {
      enable = true;
      enableCompletion = false;
      dotDir = "${config.home.homeDirectory}/.config/zsh";

      oh-my-zsh = {
        enable = true;
        plugins = [
          "git"
          "sudo"
          "docker"
        ];
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

      initContent = ''
        mcd() { mkdir -p "$1" && cd "$1"; }

        # source profileExtra
        source ${config.home.homeDirectory}/.config/zsh/.zprofile
      '';

      profileExtra = ''
        if [ -f "${config.home.profileDirectory}/etc/profile.d/nix.sh" ]; then
          source "${config.home.profileDirectory}/etc/profile.d/nix.sh"
        fi

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
          name = "autosuggestions";
          src = pkgs.zsh-autosuggestions;
          file = "share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh";
        }

        {
          name = "fast-syntax-highlighting";
          src = pkgs.zsh-fast-syntax-highlighting;
          file = "share/zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh";
        }
      ];
    };

    starship = {
      enable = true;
      enableZshIntegration = true;
      presets = [ "catppuccin-powerline" ];
      settings = {
        add_newline = false;
        # The preset disables line_break, leaving the ❯ inline with the
        # powerline bar; re-enable it so the prompt character gets its own line.
        line_break.disabled = false;
        # The preset already truncates to 3 components, but inside a git repo
        # the default truncate_to_repo collapses the path to the repo root
        # alone; disable it so 3 components always show.
        directory.truncate_to_repo = false;
      };
    };

    direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };
  };
}
