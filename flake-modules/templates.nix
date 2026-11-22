{self, ...}: {
  flake.templates = {
    default = {
      path = self + /templates/home-manager-wrapper;
      description = "Standalone Home Manager wrapper using the public nixhm module";
    };

    home-manager-wrapper = {
      path = self + /templates/home-manager-wrapper;
      description = "Standalone Home Manager wrapper using the public nixhm module";
    };
  };
}
