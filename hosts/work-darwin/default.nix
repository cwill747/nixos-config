{ config, pkgs, lib, inputs, ... }:

{
  # Fix for GID mismatch - set to match existing Nix installation
  ids.gids.nixbld = 350;

  # Work-specific system packages (in addition to shared ones)
  environment.systemPackages = with pkgs; [
    # DevOps tools that may have license issues
    terraform
    ansible

    # Database tools
    postgresql

    # Network analysis
    wireshark-cli  # CLI version for macOS
  ];

  # Work-specific Homebrew configuration (extends shared config)
  homebrew = {
    # Work-specific Mac App Store apps (in addition to shared ones)
    masApps = {
      "Microsoft To Do" = 1274495053;
    };

    # Work-specific Homebrew casks (in addition to shared ones)
    # Note: Removed packages now managed by Nix: 1password-cli, aerial, gimp, hex-fiend,
    # mactex, postman, powershell, utm, vnc-viewer, wezterm, wireshark,
    # Note: vagrant kept as cask due to complex native dependencies
    casks = [
      "clion"
      "corretto@8"
      "datagrip"
      "goland"
      "microsoft-onenote"
      "microsoft-outlook"
      "microsoft-powerpoint"
      "microsoft-teams"
      "moom"
      "slack"
      "yubico-authenticator"
    ];
  };
}
