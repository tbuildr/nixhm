{...}: {
  flake.homeModules.yazi = {pkgs, ...}: {
    home.packages = [
      pkgs.yazi
    ];

    xdg.configFile = {
      "yazi/init.lua".source =
        ../dotfiles/yazi/init.lua;

      "yazi/yazi.toml".source =
        ../dotfiles/yazi/yazi.toml;
    };
  };
}
