{self, ...}: {
  flake.homeModules.terminal = {
    xdg.configFile = {
      "kitty/kitty.conf".source =
        self + /dotfiles/kitty/kitty.conf;
    };
  };
}
