{
  inputs = {
    stable.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-wsl.url = "github:nix-community/NixOS-WSL";
  };

  outputs =
    {
      stable,
      nixpkgs-unstable,
      nixos-wsl,
      ...
    }:
    {
      nixosConfigurations.nixos = stable.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          nixos-wsl.nixosModules.default
          (
            { pkgs, ... }:
            {
              system.stateVersion = "25.05";
              wsl.enable = true;

              wsl.defaultUser = "steven";
              time.timeZone = "America/New_York";

              nix.settings.experimental-features = [
                "nix-command"
                "flakes"
              ];

              programs.nix-ld.enable = true;

              nixpkgs.overlays = [
                (_final: prev: {
                  unstable = import nixpkgs-unstable {
                    inherit (prev) system;
                    config.allowUnfree = true;
                  };
                })
              ];

              environment.systemPackages =
                let
                  stablePkgs = with pkgs; [
                    curl
                    fish
                    git
                    vim
                    wget
                  ];
                  unstablePkgs = with pkgs.unstable; [
                    lazygit
                    neovim
                    nil
                    nixfmt-rfc-style
                    zellij
                  ];
                in
                stablePkgs ++ unstablePkgs;
            }
          )
        ];
      };
    };
}
