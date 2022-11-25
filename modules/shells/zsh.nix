{ config, pkgs, ... }:

{
  programs = {
    zsh = {
      enable = true;
      enableCompletion = false;
      dotDir = ".config/zsh";

      shellAliases = {
        ll = "ls -lh";
        la = "ls -lah";
      };

      shellGlobalAliases = {
        "..." = "../..";
        "...." = "../../..";
        "....." = "../../../..";
        "......" = "../../../../..";
      };

      #ohMyZsh = {
      #  enable = true;
      #};

      initExtra = ''
        bindkey '^[[1;5D' backward-word
        bindkey '^[[1;5C' forward-word

        # source profileExtra
        source ${config.home.homeDirectory}/.config/zsh/.zprofile
      '';

      profileExtra = ''
      if [ -f "${config.home.profileDirectory}/etc/profile.d/nix.sh" ]; then
        source "${config.home.profileDirectory}/etc/profile.d/nix.sh"
      fi

      source ${config.home.homeDirectory}/.config/zsh/lib/git.plugin.zsh

      _HM_SESS_VARS_SOURCED= . $HOME/.nix-profile/etc/profile.d/hm-session-vars.sh
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

        {
          name = "powerline10k-config";
          src = ./configs;
          file = "p10k.zsh";
        }
      ];
    };
  };

  home.file.".config/zsh/lib/git.plugin.zsh".source = ./configs/git.plugin.zsh;

}
