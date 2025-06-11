{ config, pkgs, lib, inputs, ... }:

{
  # Personal-specific system packages (in addition to shared ones)
  environment.systemPackages = with pkgs; [
    youtube-dl
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
}
