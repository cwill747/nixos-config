{ config, lib, pkgs, ... }:

{
  # Linux-specific home-manager configuration
  home.homeDirectory = "/home/cameron";

  nixpkgs = {
    config = {
      allowUnfree = true;
    };
  };

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
    jetbrains.clion
    jetbrains.jdk
    docker
    docker-compose
    llvmPackages_18.stdenv
    gcc13
  ];
}
