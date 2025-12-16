{ pkgs, username, ... }:
{
  wsl = {
    enable = true;
    useWindowsDriver = true;
    defaultUser = username;
    interop.register = true;
  };

  environment.systemPackages = with pkgs; [
    wl-clipboard
    wsl-open
    xdg-utils
  ];

  nixpkgs.overlays = [
    (_final: prev: {
      xdg-utils = prev.symlinkJoin {
        name = "xdg-utils-wsl";
        paths = [ prev.xdg-utils ];
        postBuild = ''
          ln -sf ${prev.wsl-open}/bin/wsl-open $out/bin/xdg-open
        '';
      };
    })
  ];
}
