{ config, pkgs, lib, inputs, user, homeDir, ... }:

{
  imports = [
    inputs.agenix.nixosModules.default
  ];

  networking = {
    networkmanager.enable = true;
    firewall.enable = true;
  };
  i18n.defaultLocale = "en_US.UTF-8";

  programs._1password.enable = true;

  # System packages
  environment.systemPackages = with pkgs; [
    # Linux-specific packages
    chromium

    # System utilities
    usbutils
    pciutils
    lshw

    ninja

    corretto21
    inputs.agenix.packages."${pkgs.system}".default
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
      enable = false;
    };
    displayManager.gdm.enable = false;
    desktopManager.gnome.enable = false;
  };

  virtualisation = {
    docker.enable = true;
  };

  # User configuration
  users.users.${user} = {
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

  programs.mosh.enable = true;

  programs.ssh = {
    enableAskPassword = false;
    startAgent = true;
  };
}
