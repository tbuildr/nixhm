{moduleWithSystem, ...}: let
  imageName = "localhost/toolbox-tom:44";
in {
  # Reusable Home Manager module.
  flake.homeModules.toolbox = moduleWithSystem (
    {self', ...}: {...}: {
      # Make this image the default for newly created Toolbx containers.
      xdg.configFile."containers/toolbox.conf".text = ''
        [general]
        image = "${imageName}"
      '';

      # Declaratively create the custom Toolbx Containerfile.
      xdg.configFile."toolbox-tom/Containerfile".text = ''
        FROM registry.fedoraproject.org/fedora-toolbox:44

        RUN dnf -y install \
          bat \
          btop \
          eza \
          git \
          fastfetch \
          fd-find \
          fish \
          fzf \
          kitty-terminfo \
          neovim \
          ripgrep \
          zoxide \
          && dnf clean all

        # Make the host Nix store available at the path expected by
        # Home Manager symlinks and Nix-installed programs.
        RUN test ! -e /nix \
          && ln -s /run/host/nix /nix
      '';

      # Podman Quadlet build definition.
      xdg.configFile."containers/systemd/toolbox-tom.build".text = ''
        [Unit]
        Description=Build Tom's custom Toolbx image

        [Build]
        ImageTag=${imageName}
        File=%h/.config/toolbox-tom/Containerfile
        SetWorkingDirectory=%h/.config/toolbox-tom
        Pull=newer
        PodmanArgs=--squash
      '';

      # Install the system-appropriate build command.
      home.packages = [
        self'.packages.toolbox-image-build
      ];
    }
  );

  perSystem = {
    config,
    pkgs,
    ...
  }: {
    # Buildable package:
    #   nix build .#toolbox-image-build
    packages.toolbox-image-build = pkgs.writeShellScriptBin "toolbox-image-build" ''
      set -euo pipefail

      /usr/bin/podman build \
        --squash \
        --pull=newer \
        --tag "${imageName}" \
        --file "$HOME/.config/toolbox-tom/Containerfile" \
        "$HOME/.config/toolbox-tom"
    '';

    # Runnable flake app:
    #   nix run .#toolbox-image-build
    apps.toolbox-image-build = {
      type = "app";
      program = "${config.packages.toolbox-image-build}/bin/toolbox-image-build";

      meta.description = "Build Tom's custom Toolbx image";
    };
  };
}
