{inputs, ...}: {
  # Deploys herdr-dips (github:tbuildr/herdr-dips, a flake = false input) into
  # ~/.config/herdr-app as WRITABLE copies: the app writes jsconfig.json/.d.ts
  # into mod folders, so read-only store links would break it.
  #
  # Follows the guide's install rules: never overwrite a name it didn't put
  # there (shipped mods/layouts/themes, or ones added by hand) -- those are
  # skipped with a warning. Items not ready yet (a mod without main.js) are
  # skipped. keys.json files are NOT merged: do that by hand.
  #
  # Moves only on `nix flake update herdr-dips`, after aw review + land.
  flake.homeModules.herdr-dips = {
    config,
    lib,
    ...
  }: {
    home.activation.herdrDips = lib.hm.dag.entryAfter ["writeBoundary"] ''
      src=${inputs.herdr-dips}/herdr
      dst=${config.xdg.configHome}/herdr-app
      man="$dst/.herdr-dips-managed"

      if [ ! -d "$dst" ]; then
        echo "herdr-dips: $dst missing; start Herdr once, then switch again" >&2
      else
        [ -e "$man" ] || run touch "$man"

        place() { # $1 = source path, $2 = target relative to $dst
          if [ -e "$dst/$2" ] && ! grep -qxF "$2" "$man" 2>/dev/null; then
            echo "herdr-dips: $2 exists and isn't managed by herdr-dips: skipped" >&2
            return 0
          fi
          run rm -rf "$dst/$2"
          run mkdir -p "$(dirname "$dst/$2")"
          run cp -r --no-preserve=mode "$1" "$dst/$2"
          run rm -f "$dst/$2/.gitkeep"
          grep -qxF "$2" "$man" 2>/dev/null || run sh -c 'printf "%s\n" "$1" >> "$2"' _ "$2" "$man"
          echo "herdr-dips: $2"
        }

        for item in "$src"/*/; do
          for m in "$item"mods/*/; do
            [ -f "$m/main.js" ] && place "''${m%/}" "mods/$(basename "$m")"
          done
          for f in "$item"layouts/*.json "$item"layouts/*.svg "$item"layouts/*.png; do
            [ -f "$f" ] && place "$f" "layouts/$(basename "$f")"
          done
          for f in "$item"themes/*.json; do
            [ -f "$f" ] && place "$f" "themes/$(basename "$f")"
          done
          [ -f "$item/keys.json" ] && echo "herdr-dips: $(basename "$item")/keys.json: merge into keys.json by hand" >&2
        done
      fi
    '';
  };
}
