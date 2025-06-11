{ lib, pkgs, inputs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  # Enable flakes and new nix command
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      trusted-users = [ "root" "@admin" "@wheel" ];
    };

    # Keep inputs available for debugging
    registry = lib.mapAttrs (_: value: { flake = value; }) inputs;
  };

  # Common packages available on all systems
  environment.systemPackages = with pkgs; [
    # Essential CLI tools
    git
    git-lfs
    vim
    neovim
    curl
    wget
    htop
    tree
    jq
    yq
    ripgrep
    fzf
    direnv
    mise  # formerly rtx/asdf

    # Terminal enhancements
    tree-sitter
    eza  # modern replacement for ls (formerly exa)
    bat
    delta

    # Development tools and languages
    go
    nodejs
    yarn
    python3
    pipenv
    ruby
    rustup
    cmake
    gcc
    gnumake  # GNU make
    pkg-config

    # DevOps and Infrastructure (basic tools)
    kubectl
    k9s
    docker-compose

    # Database tools
    redis
    sqlite

    # Network and security tools
    nmap
    gnupg
    openssl

    # Text processing and utilities
    imagemagick
    unzip
    p7zip
    watch
    coreutils

    # Cross-platform applications (moved from Homebrew casks)
    _1password-cli
    postman
    powershell
    wireshark  # GUI version (CLI already included elsewhere)
  ];

  programs.fish.enable = true;

  # Time zone (can be overridden per host)
  time.timeZone = lib.mkDefault "America/New_York";

  environment.variables = {
    ADBLOCK = "1";
    DISABLE_OPENCOLLECTIVE = "1";
    LANG = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
  };
}
