{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-wsl.url = "github:nix-community/NixOS-WSL";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      nixpkgs-unstable,
      nixos-wsl,
      home-manager,
      ...
    }@inputs:
    {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          nixos-wsl.nixosModules.default
          home-manager.nixosModules.home-manager
          (
            { pkgs, ... }:
            let
              username = "steven";
            in
            {
              system.stateVersion = "25.05";
              wsl.enable = true;

              wsl.defaultUser = username;
              time.timeZone = "America/New_York";

              nix = {
                registry = {
                  unstable.flake = nixpkgs-unstable;
                };

                settings = {
                  auto-optimise-store = true;
                  experimental-features = [
                    "nix-command"
                    "flakes"
                  ];
                  trusted-users = [ username ];
                };
              };

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

              services.openssh = {
                enable = true;

                settings = {
                  PermitRootLogin = "no";
                  PasswordAuthentication = false;
                };
              };

              virtualisation.podman = {
                enable = true;
                dockerCompat = true;
                dockerSocket.enable = true;
                defaultNetwork.settings.dns_enabled = true;
                package = pkgs.unstable.podman;
              };

              users.users.${username} = {
                shell = pkgs.fish;
                openssh.authorizedKeys.keys = [
                  "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAxNSrwubJSzASpdG2Tb2KuqCwfv0QQHtSEySnDlxycPrtQf1LUNyItrGxBXUPf0b3lALV64DAOSoko8w2WbiwqUcQKnDAN5uOtxgO+bCprzEsyI7eIH/xUkG2p/xX3VNxaJQVnvgfesLuiJNfVdupbKFDO7xVJ2ByfViiG8EP9cBv3a62yu6bDnqyh8fXy0YTtxu6iPhQ46kt5rr2OaaKgOacokYwmJ2OW43j/GnFPpUueyRH3Zk5X7nSFbySTKUmnPjHkh4vUTcvxyEPpT1g01JOmvdVx9eCLsB0wx8Pxso1d7Nd5u+D+e7c3LWLWddw1TKwFfO5GLRHXA4fsyKSew=="
                ];
              };

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
                users.${username} = ./home.nix;
                extraSpecialArgs = { inherit inputs; };
              };
            }
          )
        ];
      };
    };
}
