{ config, pkgs, lib, inputs, user, homeDir, ... }:

{
  imports = [
    ./dock
    inputs.agenix.darwinModules.default
  ];

  ids.gids.nixbld = 350;

  users.users.${user} = {
    name = user;
    home = homeDir;
    shell = pkgs.fish;
  };

  system = {
    stateVersion = 4;
    primaryUser = user;

    defaults = {
      # Dock settings (using work Mac defaults)
      dock = {
        autohide = false;  # Work Mac setting
        autohide-delay = 0.0;
        autohide-time-modifier = 0.2;
        orientation = "bottom";
        tilesize = 48;
        minimize-to-application = true;
        show-recents = false;
      };

      # Finder settings (identical between both)
      finder = {
        AppleShowAllExtensions = true;
        AppleShowAllFiles = true;
        ShowPathbar = true;
        ShowStatusBar = true;
        FXDefaultSearchScope = "SCcf";
        FXEnableExtensionChangeWarning = false;
        _FXShowPosixPathInTitle = true;
      };

      # Global system settings (identical between both)
      NSGlobalDomain = {
        AppleShowAllExtensions = true;
        AppleShowScrollBars = "Always";
        InitialKeyRepeat = 15;
        KeyRepeat = 2;
        NSAutomaticCapitalizationEnabled = false;
        NSAutomaticDashSubstitutionEnabled = false;
        NSAutomaticPeriodSubstitutionEnabled = false;
        NSAutomaticQuoteSubstitutionEnabled = false;
        NSAutomaticSpellingCorrectionEnabled = false;
        NSNavPanelExpandedStateForSaveMode = true;
        NSNavPanelExpandedStateForSaveMode2 = true;
        PMPrintingExpandedStateForPrint = true;
        PMPrintingExpandedStateForPrint2 = true;
      };

      # Trackpad settings (identical between both)
      trackpad = {
        Clicking = true;
        TrackpadRightClick = true;
        TrackpadThreeFingerDrag = true;
      };

      # Menu bar settings (identical between both)
      menuExtraClock = {
        ShowSeconds = true;
        ShowDate = 1; # Always show date
      };
    };

    # Keyboard settings (using work Mac defaults)
    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToControl = lib.mkDefault false;
    };
  };

  # Common macOS system packages
  environment.systemPackages = with pkgs; [
    # macOS development tools
    xcode-install

    # Development tools
    docker

    # macOS-specific utilities
    mas  # Mac App Store CLI
    duti  # Set default applications

    # Media processing
    ffmpeg

    # macOS-specific applications (moved from Homebrew casks)
    hexfiend  # Hex editor for macOS
    utm        # macOS virtualization

    inputs.agenix.packages."${pkgs.system}".default
  ];

  # Common Homebrew configuration
  homebrew = {
    enable = true;
    onActivation = {
      cleanup = "none";  # Don't uninstall programs not listed
      autoUpdate = true;
      upgrade = true;
    };

    # Common Mac App Store apps
    masApps = {
      "Amphetamine" = 937984704;
      "Xcode" = 497799835;
      "Infuse" = 1136220934;
      "openterface" = 6478481082;
      "Pins" = 1547106997;
    };

    # Common Homebrew casks
    casks = [
      "betterdisplay"
      "beyond-compare"
      "db-browser-for-sqlite"
      "docker"
      "firefox"
      "font-hack-nerd-font"
      "font-hack"
      "ghostty"
      "github"
      "google-chrome"
      "intellij-idea"
      "jetbrains-gateway"
      "jetbrains-toolbox"
      "microsoft-auto-update"
      "microsoft-edge"
      "microsoft-excel"
      "microsoft-word"
      "remarkable"
      "royal-tsx"
      "steelseries-gg"
      "visual-studio-code"
      "vlc"
      "windows-app"
    ];
  };

  # Common fonts
  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.droid-sans-mono
    nerd-fonts.hack
    fira-code
    fira-code-symbols
    nerd-fonts.jetbrains-mono
    jetbrains-mono
  ];

  # Enable nix-darwin to manage the system
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      trusted-users = [ "root" "cameron" ];
    };
    gc = {
      automatic = true;
      interval = { Weekday = 0; Hour = 2; Minute = 0; };
      options = "--delete-older-than 30d";
    };
  };
}
