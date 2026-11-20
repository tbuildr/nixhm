{inputs, ...}: {
  flake.homeModules.nixgl = {
    targets.genericLinux.nixGL = {
      packages = inputs.nixGL.packages;
      defaultWrapper = "mesa";
      vulkan.enable = true;
    };
  };
}
