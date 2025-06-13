{ config, lib, pkgs, inputs, ... }:

{
  # Ubuntu/Linux system configuration

  imports = [
    ./hardware-configuration.nix  # Will need to be generated on the target system
  ];

  # Boot configuration (adjust based on your system)
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  # Network configuration
  networking = {
    hostName = "cwill-nixos-jump";
  };

  environment.sessionVariables = {
    CC = "clang";
    CXX = "clang++";
    CXXFLAGS="-I${pkgs.llvmPackages_18.libcxx}/include/c++/v1";
    LDFLAGS="-L${pkgs.llvmPackages_18.libcxx}/lib";
  };


  environment.systemPackages = with pkgs; [
    llvmPackages_18.libcxxClang
    llvmPackages_18.libcxx
    llvmPackages_18.stdenv
    libiconv
    autoconf
    automake
    libtool
    ninja
    cmake
    gnumake  # GNU make
  ];

  programs.nix-ld = {
    enable = true;
  };



  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken.
  system.stateVersion = "24.05";
}
