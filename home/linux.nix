{ config, lib, pkgs, ... }:

{
  # Linux-specific home-manager configuration

  # Add Linux-specific paths and settings to fish
  programs.fish.shellInit = lib.mkBefore ''
    # Linux-specific paths
    fish_add_path /usr/local/sbin
  '';

  # XDG directories for Linux
  xdg = {
    enable = true;
    userDirs = {
      enable = true;
      createDirectories = true;
    };
  };

  home.packages = with pkgs; [
    jetbrains.clion
    jetbrains.jdk
    docker
    docker-compose
  ];
}
