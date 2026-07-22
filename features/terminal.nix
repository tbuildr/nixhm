{...}: {
  flake.homeModules.terminal = {
    xdg.configFile = {
      "fastfetch/config.jsonc".source =
        ../dotfiles/fastfetch/config.jsonc;

      "kitty/kitty.conf".source =
        ../dotfiles/kitty/kitty.conf;
    };
  };
}
