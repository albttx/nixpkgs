{ inputs, pkgs, lib, config, ... }: {
  home.file.".config/awesome".source =
    config.lib.file.mkOutOfStoreSymlink ./config;

  xsession = {
    enable = true;
    scriptPath = ".hm-xsession";

    windowManager.awesome = {
      enable = false;
      # package = inputs.awesome-git;
      package = pkgs.awesome;

      # luaModules = with pkgs; [ lain ];
      # luaModules = with pkgs.luaPackages; [
      #   luarocks     # is the package manager for Lua modules
      #   luadbi-mysql # Database abstraction layer
      # ];
    };
  };
}
