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
          fastfetch
          fd
          fzf
          lazygit
          neovim
          nil
          nixfmt-rfc-style
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
    };
  };
}
