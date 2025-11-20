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
          killall
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
          delta
          dust
          eza
          fastfetch
          fd
          fzf
          hexyl
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

        fzf_configure_bindings --git_status= --git_log=

        bind ctrl-alt-l _lazygit_log
        bind ctrl-alt-s _lazygit_status

        fastfetch
      '';

      functions = {
        _lazygit_status = builtins.readFile ./fishFuncs/_lazygit_status.fish;
        _lazygit_log = builtins.readFile ./fishFuncs/_lazygit_log.fish;
      };

      shellAliases = {
        du = "dust";
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
          inherit (fzf-fish) src;
          name = "fzf.fish";
        }
        {
          inherit (tide) src;
          name = "tide";
        }
      ];
    };

    lazygit = {
      enable = true;
      package = pkgs.unstable.lazygit;
      settings = {
        gui = {
          nerdFontsVersion = "3";
          spinner = {
            rate = 500;
            frames = [
              "🕛 "
              "🕐 "
              "🕑 "
              "🕒 "
              "🕓 "
              "🕔 "
              "🕕 "
              "🕖 "
              "🕗 "
              "🕘 "
              "🕙 "
              "🕚 "
            ];
          };
        };
        git = {
          ignoreWhitespaceInDiffView = true;
          log = {
            showGraph = "when-maximised";

            # i have had this as true for a long time,
            # but i'm thinking it's not great. let's try this
            showWholeGraph = false;
          };
          pagers = [
            {
              colorArg = "always";
              pager = "delta --dark --paging=never";
            }
          ];
        };
      };
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
