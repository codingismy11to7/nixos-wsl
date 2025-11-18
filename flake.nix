{
  inputs = {
    stable.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-wsl.url = "github:nix-community/NixOS-WSL";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  outputs =
    {
      stable,
      nixpkgs-unstable,
      nixos-wsl,
      home-manager,
      ...
    }:
    {
      nixosConfigurations.nixos = stable.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          nixos-wsl.nixosModules.default
          home-manager.nixosModules.home-manager
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

              programs = {
                nix-ld.enable = true;
                fish = {
                  enable = true;
                  useBabelfish = true;
                };

                ssh = {
                  startAgent = true;
                };
              };

              users.users.steven.shell = pkgs.fish;

              nixpkgs.overlays = [
                (_final: prev: {
                  unstable = import nixpkgs-unstable {
                    inherit (prev) system;
                    config.allowUnfree = true;
                  };
                })
              ];

              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                backupFileExtension = "hmbackup";
                users.steven = ./home.nix;
              };
            }
          )
        ];
      };
    };
}
