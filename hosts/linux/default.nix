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
    hostName = "cwill-ubuntu-jump";
    networkmanager.enable = true;
    # firewall.enable = true;  # Enable if needed
  };

  # System packages
  environment.systemPackages = with pkgs; [
    # Linux-specific packages
    firefox
    chromium

    # Development tools
    docker
    docker-compose

    # System utilities
    usbutils
    pciutils
    lshw
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

  };

  # Virtualization
  virtualisation = {
    # Docker service
    docker.enable = true;

    # Enable automatic updates (optional)
    # automatic-upgrade.enable = true;
  };

  # User configuration
  users.users.cameron = {
    isNormalUser = true;
    description = "Cameron Williams";
    extraGroups = [ "wheel" "networkmanager" "docker" ];
    shell = pkgs.fish;
    ignoreShellProgramCheck = true;  # Fish is managed by home-manager
    openssh.authorizedKeys.keys = [
      # Add your SSH public keys here
      # "ssh-rsa AAAAB3Nza... your-key-here"
    ];
  };

  # Security settings
  security = {
    sudo.wheelNeedsPassword = true;
    rtkit.enable = true;  # For audio
  };

  # Audio support (using PipeWire - modern alternative to PulseAudio)
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken.
  system.stateVersion = "24.05";
}
