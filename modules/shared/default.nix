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
    ripgrep
    fzf
    mosh

    eza  # modern replacement for ls (formerly exa)
    bat

    # Development tools and languages
    pipenv
    ruby
    rustup
    pkg-config
    firefox
    # DevOps and Infrastructure (basic tools)
    kubectl
    k9s

    # Database tools
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

    inputs.agenix.packages."${system}".default
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
