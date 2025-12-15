{
  lib,
  pkgs,
  ...
}:
let
  join = lib.concatStringsSep " ";
in
{
  programs.fish = {
    enable = true;

    interactiveShellInit = ''
      set fish_greeting

      fzf_configure_bindings --git_status= --git_log=

      bind ctrl-alt-l _lazygit_log
      bind ctrl-alt-s _lazygit_status

      fastfetch
    '';

    functions = {
      _in_zellij = builtins.readFile ./fishFuncs/_in_zellij.fish;
      _lazygit_status = builtins.readFile ./fishFuncs/_lazygit_status.fish;
      _lazygit_log = builtins.readFile ./fishFuncs/_lazygit_log.fish;
      _run_cmd_in_zellij_popup = builtins.readFile ./fishFuncs/_run_cmd_in_zellij_popup.fish;
    };

    shellAliases = {
      cat = "bat";
      du = "dust";
      lg = "lazygit";
      ls = "eza";
      vim = "nvim";

      gembot = "npx -y @google/gemini-cli@latest";
    };

    shellAbbrs = {
      reb = "nh os switch";
    };

    plugins = with pkgs.fishPlugins; [
      {
        name = "bass";
        src = bass.src;
      }
      {
        name = "fzf.fish";
        src = fzf-fish.src;
      }
      {
        name = "tide";
        src = tide.src;
      }
    ];
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

        fish_function_path=${pkgs.fishPlugins.tide}/share/fish/vendor_functions.d/ \
          ${pkgs.fish}/bin/fish --interactive --command "${join tideArgs}"
      ''
    );
  };
}
