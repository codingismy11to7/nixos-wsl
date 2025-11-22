## Project Overview

This repository contains personal dotfiles for a development environment, managed declaratively using the Nix ecosystem. It's designed for a NixOS system running under WSL (Windows Subsystem for Linux), but parts can be adapted for other systems.

The core of the setup is a Nix Flake (`flake.nix`) which defines the system-level configuration and a Home Manager configuration (`home.nix`) which manages the user-specific environment, packages, and application settings.

**Key Technologies:**

* **Nix:** The primary package and configuration manager.
* **NixOS:** The declarative Linux distribution.
* **Home Manager:** For managing the user environment (`home.nix`).
* **Fish Shell:** The default shell, configured with plugins, aliases, and custom functions.
* **Neovim:** The text editor, with a configuration managed in `nvim/`. This is a LazyVim based setup.
* **sops-nix:** For managing secrets declaratively.

## Building and Running

The primary action in this repository is to apply the configuration to the system.

**Apply the configuration:**

```bash
sudo nixos-rebuild switch --flake .
```

A shell abbreviation `reb` is also available in the fish shell for this command.

To perform a dry-run without applying changes (no sudo needed):

```bash
nixos-rebuild dry-build --flake .
```

There are no traditional "run" or "test" commands. The main workflow is to modify the `.nix` files and apply the changes.

## Development Conventions

* **System Configuration:** All system-level configuration is in `flake.nix`.
* **User Environment:** User-specific packages, aliases, environment variables, and application settings are defined in `home.nix`.
* **Package Management:** Packages are installed via `home.packages` in `home.nix`. Packages are sourced from both `stable` and `unstable` nixpkgs channels.
* **Neovim:** The Neovim configuration is located in the `nvim/` directory and is symlinked into the XDG config path. It appears to be a LazyVim based setup.
* **Shell:** The fish shell is heavily customized in `home.nix`, including custom functions loaded from the `fishFuncs/` directory.
* **Secrets:** Secrets are managed by `sops-nix`, with `secrets/secrets.json` holding multiple secrets and encrypted with an age key stored in `secrets/keys.txt`. To update secrets, use the command `sops edit ./secrets/secrets.json`.
