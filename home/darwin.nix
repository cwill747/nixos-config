{ config, lib, pkgs, user, homeDir, ... }:

{

  # macOS-specific home-manager configuration
  home.homeDirectory = homeDir;

  # Add macOS-specific paths and settings to fish
  programs.fish = {
    shellInit = lib.mkBefore ''
      # iTerm2 shell integration
      test -e ~/.iterm2_shell_integration.fish ; and source ~/.iterm2_shell_integration.fish
    '';

    # macOS-specific aliases
    shellAliases = lib.mkMerge [
      {
        # Nix/Darwin aliases for easier management
        "rebuild" = "sudo darwin-rebuild switch --flake ~/.config/nixos#$(hostname)";
        "rebuild-check" = "darwin-rebuild check --flake ~/.config/nixos#$(hostname)";
      }
    ];

    plugins = lib.mkMerge [];
  };

  # macOS-specific packages
  home.packages = with pkgs; [
    # macOS-specific or preferred packages
  ];
}
