{ pkgs, ... }:
{
  home = {
    stateVersion = "25.05";

    sessionVariables.EDITOR = "nvim";

    packages =
      let
        stablePkgs = with pkgs; [
          curl
          file
          git
          unzip
          vim
          wget
          zip
        ];
        unstablePkgs = with pkgs.unstable; [
          bat
          broot
          btop
          chafa
          eza
          fastfetch
          fd
          fzf
          hexyl
          lazygit
          neovim
          nil
          nixfmt-rfc-style
          procs
          ripgrep
          tree
          zellij
        ];
      in
      stablePkgs ++ unstablePkgs;
  };

  programs = {
    fish = {
      enable = true;

      interactiveShellInit = ''
        set fish_greeting

        fastfetch
      '';

      shellAliases = {
        lg = "lazygit";
        vim = "nvim";
      };

      plugins = with pkgs.fishPlugins; [
        {
          inherit (bass) src;
          name = "bass";
        }
        {
          inherit (tide) src;
          name = "tide";
        }
      ];
    };
  };
}
