{
  inputs = {
    stable.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-wsl.url = "github:nix-community/NixOS-WSL";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "stable";
    };
  };

  outputs =
    {
      stable,
      nixpkgs-unstable,
      nixos-wsl,
      home-manager,
      ...
    }@inputs:
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

              virtualisation.podman = {
                enable = true;
                dockerCompat = true;
                dockerSocket.enable = true;
                defaultNetwork.settings.dns_enabled = true;
                package = pkgs.unstable.podman;
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
                extraSpecialArgs = { inherit inputs; };
              };
            }
          )
        ];
      };
    };
}
