{ config, pkgs, lib, inputs, ... }:

{
  environment.systemPackages = with pkgs; [
  ];

  # Personal-specific Homebrew configuration (extends shared config)
  homebrew = {
    # Personal Mac App Store apps (in addition to shared ones)
    masApps = {
    };

    # Personal Homebrew casks (in addition to shared ones)
    casks = [
      "discord"
      "steam"
    ];
  };

  local.dock = {
    enable = false;
    username = "cameron";
  };
}
