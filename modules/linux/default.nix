{ config, pkgs, lib, inputs, ... }:

{
  networking = {
    networkmanager.enable = true;
  };
  i18n.defaultLocale = "en_US.UTF-8";

    # System packages
  environment.systemPackages = with pkgs; [
    # Linux-specific packages
    chromium

    # System utilities
    usbutils
    pciutils
    lshw

    libiconv
    autoconf
    automake
    libtool

    ninja

    corretto21

    # Compiler toolchain
    llvmPackages_20.libcxxClang
    llvmPackages_20.libcxx
  ];
  # Services
  services = {
    # Enable SSH daemon
    openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "no";
      };
    };
    xserver = {
      enable = true;
    };
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
  };

  virtualisation = {
    docker.enable = true;
  };

  # User configuration
  users.users.cameron = {
    isNormalUser = true;
    description = "Cameron Will";
    extraGroups = [ "wheel" "networkmanager" "docker" ];
    shell = pkgs.fish;
    group = "users";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJqEbrcnMGRBheEpSU1oFrLQ/dtDk99a/cENj6ZGFXIK"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM3R0YccWM9guxFI3vshjLk6H1YIhXcQHicwuz6VOivt"
    ];
  };

  programs.firefox.enable = true;
  programs.fish.enable = true;
  programs.neovim.enable = true;
  programs.neovim.defaultEditor = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # Security settings
  security = {
    sudo.wheelNeedsPassword = true;
  };
# Audio support (using PipeWire - modern alternative to PulseAudio)
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Fish likes doing this - https://discourse.nixos.org/t/slow-build-at-building-man-cache/52365/6
  documentation.man.generateCaches = false;

}