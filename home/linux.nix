{ config, lib, pkgs, user, homeDir, ... }:

{
  # Linux-specific home-manager configuration
  home.homeDirectory = homeDir;

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

  # Environment variables for linking
  home.sessionVariables = {
    CC = "clang";
    CXX = "clang++";
  };

  programs.jetbrains-remote = {
    enable = true;
    ides = with pkgs.jetbrains; [
      clion
    ];
  };

  home.packages = with pkgs; [
    jetbrains.jdk
    docker
    docker-compose
  ];
}
