{ config, lib, pkgs, inputs, ... }:

{
  # Ubuntu/Linux system configuration

  imports = [
    ./hardware-configuration.nix  # Will need to be generated on the target system
  ];

  boot.initrd.kernelModules = ["hv_vmbus" "hv_storvsc"];
  boot.kernel.sysctl."vm.overcommit_memory" = "1"; # https://github.com/NixOS/nix/issues/421

  # Boot configuration (adjust based on your system)
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  # Network configuration
  networking = {
    hostName = "cwill-nixos-jump";
  };

  environment.systemPackages = with pkgs; [
    llvmPackages_18.libcxx
    clang_18
    gcc
    gnumake
    autoconf
    automake
    libtool
    ninja
    cmake
  ];

  programs.nix-ld = {
    enable = true;
  };

  virtualisation.hypervGuest.enable = true;


  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken.
  system.stateVersion = "25.05";
}
