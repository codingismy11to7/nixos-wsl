{
  config,
  inputs,
  pkgs,
  ...
}:
let
  ageKeyFile = "${config.home.homeDirectory}/dotfiles/secrets/keys.txt";
in
{
  imports = [
    inputs.sops-nix.homeManagerModules.sops
    ./home/fish.nix
  ];

  sops = {
    age.keyFile = ageKeyFile;
    defaultSopsFile = ./secrets/secrets.json;
    defaultSopsFormat = "json";

    secrets.sshPrivKey = {
      path = "${config.home.homeDirectory}/.ssh/id_rsa";
      mode = "0600";
    };
  };

  home = {
    stateVersion = "25.05";

    sessionVariables = {
      DOCKER_HOST = "unix://$\{XDG_RUNTIME_DIR}podman/podman.sock";
      EDITOR = "nvim";
      SOPS_AGE_KEY_FILE = ageKeyFile;
    };

    packages =
      let
        stablePkgs = with pkgs; [
          age
          cargo
          curl
          file
          gcc
          git
          killall
          nodejs
          sops
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
          distrobox
          distrobox-tui
          dust
          eza
          fastfetch
          fd
          fzf
          hexyl
          lazydocker
          neovim
          nil
          nixfmt-rfc-style
          podman-compose
          procs
          ripgrep
          statix
          tree
          tree-sitter
          zellij
        ];
      in
      stablePkgs ++ unstablePkgs;
  };

  xdg.configFile."nvim".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/nvim";

  programs = {
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
}
