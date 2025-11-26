{
  pkgs,
  lib,
  isGui ? false,
  ...
}:
{
  config = lib.mkIf isGui {

    home = {
      packages = with pkgs.unstable; [
        kitty
        mpv
        nautilus
      ];

      pointerCursor = {
        gtk.enable = true;
        # no idea what these are, just pulling from hyprland wiki atm
        package = pkgs.unstable.bibata-cursors;
        name = "Bibata-Modern-Classic";
        size = 16;
      };

    };

    gtk = {
      enable = true;

      # again, def not sure about all these themes and fonts and whatnot,
      # but let's just get going.
      # not sure why we wouldn't use the cursorTheme settings available here
      # also the hyprland wiki was wrong and had this whole gtk section outside
      # of a home block, so i got errors at first
      theme = {
        package = pkgs.unstable.flat-remix-gtk;
        name = "Flat-Remix-GTK-Grey-Darkest";
      };

      iconTheme = {
        package = pkgs.unstable.adwaita-icon-theme;
        name = "Adwaita";
      };

      font = {
        name = "Sans";
        size = 11;
      };

      # not gonna bump HM to unstable right now, and this is a new option
      # colorScheme = "dark";
    };

    wayland.windowManager.hyprland = {
      enable = true;

      # enabled at system level
      package = null;
      portalPackage = null;

      systemd.enableXdgAutostart = true;

      settings = {
        monitor = ",preferred,auto,auto";
        # having issues with ghostty, kitty seems like a decent replacement
        "$terminal" = "uwsm-app -- kitty";
        "$fileManager" = "uwsm-app -- nautilus --new-window";

        bindd = [
          "SUPER, RETURN, Terminal, exec, $terminal"
          "SUPER, W, Close window, killactive"
        ]
        ++ (builtins.map
          (
            dir: "SUPER, ${lib.toUpper dir}, Move window focus ${dir}, movefocus, ${builtins.substring 0 1 dir}"
          )
          [
            "up"
            "down"
            "left"
            "right"
          ]
        )
        ++ (
          # workspaces
          # binds SUPER + [shift +] {1..9} to [move to] workspace {1..9}
          builtins.concatLists (
            builtins.genList (
              i:
              let
                ws = i + 1;
              in
              [
                "SUPER, code:1${toString i}, Switch to workspace ${toString ws}, workspace, ${toString ws}"
                "SUPER SHIFT, code:1${toString i}, Move window to workspace ${toString ws}, movetoworkspace, ${toString ws}"
              ]
            ) 9
          )
        );
      };
    };
  };
}
