{ lib, pkgs, ... }:
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
        ls = "eza";
        vim = "nvim";
      };

      shellAbbrs = {
        reb = "sudo nixos-rebuild switch --flake";
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

  home.activation = {
    configureFishTide = lib.hm.dag.entryAfter [ "writeBoundary" ] (
      let
        tideArgs = [
          "tide configure"
          "--auto"
          "--style=Rainbow"
          "--prompt_colors='True color'"
          "--show_time='12-hour format'"
          "--rainbow_prompt_separators=Slanted"
          "--powerline_prompt_heads=Sharp"
          "--powerline_prompt_tails=Flat"
          "--powerline_prompt_style='Two lines, character and frame'"
          "--prompt_connection=Dotted"
          "--powerline_right_prompt_frame=No"
          "--prompt_connection_andor_frame_color=Dark"
          "--prompt_spacing=Sparse"
          "--icons='Many icons'"
          "--transient=Yes"
        ];
      in
      ''
        verboseEcho "Configuring Tide for Fish shell..."

        run ${pkgs.fish}/bin/fish -c "${lib.concatStringsSep " " tideArgs}"
      ''
    );
  };
}
