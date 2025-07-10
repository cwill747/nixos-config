{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;

  networking.hostName = "attic"; # Define your hostname.
  
  # Enable networking
  networking.networkmanager.enable = true;

  system.stateVersion = "25.05"; # Did you read the comment?

}
