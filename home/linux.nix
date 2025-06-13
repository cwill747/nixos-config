{ config, lib, pkgs, ... }:

{
  # Linux-specific home-manager configuration

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
    CXXFLAGS="-I${pkgs.llvmPackages_18.libcxx}/include/c++/v1";
    LDFLAGS="-L${pkgs.llvmPackages_18.libcxx}/lib -l:libatomic.a";
    LD_LIBRARY_PATH=$NIX_LD_LIBRARY_PATH
  };

  home.packages = with pkgs; [
    jetbrains.clion
    jetbrains.jdk
    docker
    docker-compose
    gcc-unwrapped  # Provides libatomic
  ];
}
