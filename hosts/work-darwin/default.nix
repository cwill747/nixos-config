{ config, pkgs, lib, inputs, user, homeDir, ... }:

{
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

  local.dock = {
    enable   = true;
    username = user;
    entries = [
      { path = "/Applications/Microsoft Edge.app"; }
      { path = "/Applications/Microsoft Outlook.app"; }
      { path = "/Applications/Slack.app"; }
      { path = "/Applications/Royal TSX.app"; }
      { path = "/Applications/Ghostty.app"; }
      { path = "/Applications/Visual Studio Code.app"; }
      { path = "/Applications/Cisco/Cisco Secure Client.app"; }
      { path = "/Applications/1Password.app"; }
    ];
    spacers = [
      { section = "apps"; after = "/Applications/Visual Studio Code.app"; }
    ];
  };
}
