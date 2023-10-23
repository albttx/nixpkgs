{ pkgs, ... }:

{

  home.packages = with pkgs; [
    tig
  ];

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

    #extraConfig = {
    #  gpg = {
    #    program = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
    #    format = "ssh";
    #  };
    #};


    aliases = { };

    ignores = [
      "*~"
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
