{
  nixConfig = {
    extra-substituters = [
      "https://nixos-raspberrypi.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nixos-raspberrypi.cachix.org-1:4iMO9LXa8BqhU+Rpg6LQKiGa2lsNh/j2oiYLNOQ5sPI="
    ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # develop is currently the default branch and is 23
    # commits ahead of main; main is the stable branch.
    # assuming since this device is brand new that i should
    # stay bleeding edge
    nixos-rpi.url = "github:nvmd/nixos-raspberrypi";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixos-rpi/nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      nixos-rpi,
      disko,
      home-manager,
      ...
    }@inputs:
    let
      hostname = "nixos";
      username = "steven";

      nixpkgs-unstable = nixpkgs;
    in
    {
      nixosConfigurations.${hostname} = nixos-rpi.lib.nixosSystemFull {
        specialArgs = {
          nixos-raspberrypi = nixos-rpi;
        };
        #system = "aarch64-linux";
        modules = [
          home-manager.nixosModules.home-manager
          {
            imports = with nixos-rpi.nixosModules; [
              raspberry-pi-5.base
              raspberry-pi-5.page-size-16k
              raspberry-pi-5.display-vc4
              raspberry-pi-5.bluetooth
            ];
          }
          disko.nixosModules.disko
          ./disko-nvme-btrfs.nix
          (
            { pkgs, ... }:
            {
              system.stateVersion = "25.05";
              networking.hostName = hostname;
              time.timeZone = "America/New_York";

              boot = {
                loader.raspberryPi.bootloader = "kernel";

                tmp.useTmpfs = true;
              };

              #wsl.defaultUser = username;

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
