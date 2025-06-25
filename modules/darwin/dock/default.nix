{ config, pkgs, lib, ... }:
# Original source: https://gist.github.com/antifuchs/10138c4d838a63c0a05e725ccd7bccdd

with lib;
let
  cfg = config.local.dock;
  inherit (pkgs) stdenv dockutil;
in
{
  options = {
    local.dock = {
      enable = mkOption {
        description = "Enable dock";
        default     = stdenv.isDarwin;
      };

      entries = mkOption {
        description = "Entries on the Dock";
        type =
          with types;
          listOf (submodule {
            options = {
              path    = lib.mkOption { type = str; };
              section = lib.mkOption {
                type    = str;
                default = "apps";
              };
              options = lib.mkOption {
                type    = str;
                default = "";
              };
            };
          });
        readOnly = true;
      };

      spacers = mkOption {
        description = "Spacers to add to the Dock";
        type =
          with types;
          listOf (submodule {
            options = {
              section = lib.mkOption {
                type    = str;
                default = "apps";
              };
              after = lib.mkOption {
                type    = str;
              };
            };
          });
        readOnly = true;
      };

      username = mkOption {
        description = "Username to apply the dock settings to";
        type        = types.str;
      };
    };
  };

  config = mkIf cfg.enable (
    let
      normalize = path: if hasSuffix ".app" path then path + "/" else path;
      entryURI =
        path:
        "file://"
        + (builtins.replaceStrings
          [ " " "!" "\"" "#" "$" "%" "&" "'" "(" ")" ]
          [ "%20" "%21" "%22" "%23" "%24" "%25" "%26" "%27" "%28" "%29" ]
          (normalize path)
        );

      # Create a list of entries with spacers inserted in the correct positions
      entriesWithSpacers =
        let
          # Function to insert spacers after specific entries
          insertSpacers = entries: spacers:
            if spacers == [] then entries
            else
              let
                spacer = head spacers;
                restSpacers = tail spacers;
                # Find the index of the entry to add spacer after
                entryIndex = findFirst
                  (i: (elemAt entries i).path == spacer.after)
                  null
                  (range 0 (length entries - 1));
              in
              if entryIndex == null then
                # If the "after" entry is not found, just continue with remaining spacers
                insertSpacers entries restSpacers
              else
                let
                  beforeEntries = take (entryIndex + 1) entries;
                  afterEntries = drop (entryIndex + 1) entries;
                  spacerEntry = { path = ""; section = spacer.section; options = ""; };
                in
                insertSpacers (beforeEntries ++ [ spacerEntry ] ++ afterEntries) restSpacers;
        in
        insertSpacers cfg.entries cfg.spacers;

      wantURIs = concatMapStrings
        (entry: if entry.path == "" then "\n" else "${entryURI entry.path}\n")
        entriesWithSpacers;

      createEntries =
        concatMapStrings
          (entry:
            "${dockutil}/bin/dockutil --no-restart --add '${entry.path}' --section ${entry.section} ${entry.options}\n"
          )
          cfg.entries;
      createSpacers =
        concatMapStrings
          (spacer:
            "${dockutil}/bin/dockutil --no-restart --add '' --type spacer  --section ${spacer.section} --after '${spacer.after}'\n"
          )
          cfg.spacers;
    in
    {
      system.activationScripts.postActivation.text = ''
        echo >&2 "Setting up the Dock for ${cfg.username}..."
        su ${cfg.username} <<'USERBLOCK'
      set haveURIs "$(${dockutil}/bin/dockutil --list | ${pkgs.coreutils}/bin/cut -f2)"
      if ! diff -wu (echo -n "$haveURIs" | psub) (echo -n '${wantURIs}' | psub) >&2
        echo >&2 "Resetting Dock."
        ${dockutil}/bin/dockutil --no-restart --remove all
        ${createEntries}
        ${createSpacers}
        killall Dock
      else
        echo >&2 "Dock setup complete."
      end
      USERBLOCK
      '';
    }
  );
}
