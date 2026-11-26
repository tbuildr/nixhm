{...}: {
  flake.homeModules.cli-tools = {
    config,
    pkgs,
    ...
  }: {
    home.packages = with pkgs; [
      age
      age-plugin-yubikey
      bat
      butane
      eza
      fd
      gitleaks
      # Herdr desktop app, wrapped with nixGL for GPU access on non-NixOS.
      (config.lib.nixGL.wrap herdr-desktop)
      huggingface-cli
      lazydocker
      kind
      kubectl
      kubernetes-helm
      k9s
      nodejs_24
      nmap
      passage
      rclone
      ripgrep
      shellcheck
      swappy
      tmux
      uv
      wtype
    ];
  };
}
