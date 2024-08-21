{ pkgs, ... }:

{

  home.packages = with pkgs.pkgs-master; [ tig ];

  programs.gh = {
    enable = true;
    settings.git_protocol = "ssh";
  };

  programs.git = {
    enable = true;
    userName = "albttx";
    userEmail = "contact@albttx.tech";
    signing = {
      key = "6ECDB1C9555BCE18";
      signByDefault = true;
    };

    extraConfig = {
      color.ui = true;
      color.diff = true;
      core.whitespace = "trailing-space,space-before-tab";
      diff.colorMoved = "default";
      pull.rebase = true;
    };
    aliases = { };

    ignores = [
      "*~"
      "*.swp"
      "*.bak*" # backup files
      ".*.sw?"
      "tags" # vim swap and tag files
      ".env"
      ".direnv/" # directory environment configuration files
      "vendor/"
      "node_modules/" # package manager directories
      ".DS_Store" # get rid of the mac shit
      "*.log" # you probably never want to commit a log file
      "*.md.pdf" # those get built when using :make when ft=markdown

      "Session.vim" # vim session file
      ".root" # file denoting the root of a project

      ".dir-locals.el"
    ];

  };

  programs.zsh.shellAliases = {
    gd = "git diff";
    gb = "git branch";
    gst = "git status";
    gco = "git checkout";

    gcm = "git checkout $(git_main_branch)";

    ggpull = ''git pull origin "$(git_current_branch)"'';
    ggpush = ''git push origin "$(git_current_branch)"'';
  };
}
