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
      # Original:
      # (config.lib.nixGL.wrap herdr-desktop)
      #
      # nixpkgs 0.1.10 is missing zstd in buildInputs (zstd-sys pkg-config probe fails).
      # Drop the override once nixpkgs fixes it.
      (config.lib.nixGL.wrap (herdr-desktop.overrideAttrs (old: {
        buildInputs = (old.buildInputs or []) ++ [zstd];
      })))
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
