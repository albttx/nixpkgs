{ pkgs, ... }:

{
    programs.git = {
      enable = true;
      userName = "albttx";
      userEmail = "contact@albttx.tech";
      aliases = {
      };
      ignores = [
        "*~" "*.bak*" # backup files
        ".*.sw?" "tags" # vim swap and tag files
        ".env"  ".direnv/" # directory environment configuration files
        "vendor/" "node_modules/" # package manager directories
        ".DS_Store" # get rid of the mac shit
        "*.log" # you probably never want to commit a log file
        "*.md.pdf" # those get built when using :make when ft=markdown

        "Session.vim" # vim session file
        ".root" # file denoting the root of a project
      ];

    };

    programs.zsh.shellAliases = {
      "ggpull" = "git pull origin (current_branch)";
    };
}
