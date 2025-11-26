{
  lib,
  isGui ? false,
  ...
}:
{
  config = lib.mkIf isGui {
    services = {
      displayManager.sddm = {
        enable = true;

        autoNumlock = true;

        theme = "breeze";

        wayland = {
          enable = true;
        };
      };
      xserver.xkb = {
        layout = "us";
        variant = "dvorak";
      };
    };

    programs = {
      hyprland = {
        enable = true;

        withUWSM = true;
      };

      hyprlock.enable = true;
    };

  };
}
