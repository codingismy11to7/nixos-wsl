{ config, pkgs, ... }:
{
  services.displayManager.sddm = {
    enable = true;

    autoNumlock = true;

    theme = "breeze";

    wayland = {
      enable = true;
    };
  };

  programs = {
    hyprland = {
      enable = true;

      withUWSM = true;
    };

    hyprlock.enable = true;
  };

  xdg.configFile."uwsm/env".source =
    "${config.home.sessionVariablesPackage}/etc/profile.d/hm-session-vars.sh";

  home = {
    packages = with pkgs.unstable; [
      ghostty
      nautilus
    ];

    pointerCursor = {
      gtk.enable = true;
      # no idea what these are, just pulling from hyprland wiki atm
      package = pkgs.unstable.bibata-cursors;
      name = "Bibata-Modern-Classic";
      size = 16;
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

      colorScheme = "dark";
    };

    wayland.windowManager.hyprland = {
      enable = true;

      # enabled at system level
      package = null;
      portalPackage = null;

      systemd.enableXdgAutostart = true;
    };
  };

  wayland.windowManager.hyprland.settings = {
    monitor = ",preferred,auto,auto";
    "$terminal" = "uwsm-app -- ghostty";
    "$fileManager" = "uwsm-app -- nautilus --new-window";

    bindd = [
      "SUPER, RETURN, Terminal, exec, ghostty"
      "SUPER, W, Close window, killactive"
    ]
    ++ (builtins.map
      (
        dir:
        "SUPER, ${builtins.toUpper dir}, Move window focus ${dir}, movefocus, ${builtins.substring 0 1 dir}"
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
}
