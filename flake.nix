{
  inputs = {
    stable.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixos-wsl.url = "github:nix-community/NixOS-WSL";
  };

  outputs =
    {
      stable,
      nixos-wsl,
      ...
    }:
    {
      nixosConfigurations.nixos = stable.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          nixos-wsl.nixosModules.default
          {
            system.stateVersion = "25.05";
            wsl.enable = true;

            time.timeZone = "America/New_York";

            nix.settings.experimental-features = [
              "nix-command"
              "flakes"
            ];
          }
        ];
      };
    };
}
