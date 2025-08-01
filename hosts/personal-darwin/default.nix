{ config, pkgs, lib, inputs, user, homeDir, ... }:

{
  environment.systemPackages = with pkgs; [
    discord
  ];

  # Personal-specific Homebrew configuration (extends shared config)
  homebrew = {
    # Personal Mac App Store apps (in addition to shared ones)
    masApps = {
    };

    # Personal Homebrew casks (in addition to shared ones)
    casks = [
      "steam"
    ];
  };

  local.dock = {
    enable = false;
    username = user;
  };
}
