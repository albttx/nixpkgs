{ config, pkgs, ... }:

{
  home.packages =  with pkgs; [
    oh-my-zsh
  ];

  programs = {
    zsh = {
      enable = true;
      enableCompletion = false;
      dotDir = ".config/zsh";

      oh-my-zsh = {
        enable = true;
        plugins = [
          "git"
          "sudo"
          "docker"
        ];
      };

      # shellAliases = {
      #   ll = "ls -lh";
      #   la = "ls -lah";
      # };

      # shellGlobalAliases = {
      #   "..." = "../..";
      #   "...." = "../../..";
      #   "....." = "../../../..";
      #   "......" = "../../../../..";
      # };

      initExtra =
        let
          p10k-config = "${config.home.homeDirectory}/.p10k.zsh";
        in
        ''
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

        bindkey '^[[1;5D' backward-word
        bindkey '^[[1;5C' forward-word
        bindkey '^H' backward-delete-char 
        bindkey  "^[[H"   beginning-of-line
        bindkey  "^[[F"   end-of-line

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
      ];
    };
  };

  home.file.".p10k.zsh".source = ./configs/p10k.zsh;
}
