{ lib, pkgs, inputs, agenix, ... }:

{
  imports = [
    ./utils.nix
    ./secrets.nix
  ];

  nixpkgs.config.allowUnfree = true;

  # Enable flakes and new nix command
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      trusted-users = [ "root" "@admin" "@wheel" ];
    };
    gc = {
      automatic = true;
      options = "--delete-older-than 30d";
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
    openssh
    wezterm
    attic-client

    eza  # modern replacement for ls (formerly exa)
    bat

    # Development tools and languages
    pipenv
    ruby
    rustup
    pkg-config
    firefox
    gh

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

    inputs.agenix.packages."${pkgs.system}".default

    # Secrets
    age

    # Shells
    bashInteractive
    zsh

    # Run files from nixpkgs without installing
    comma
  ];

  programs.fish.enable = true;

  environment.shells = [ pkgs.bashInteractive pkgs.zsh pkgs.fish ];

  # Time zone (can be overridden per host)
  time.timeZone = lib.mkDefault "America/New_York";

  environment.variables = {
    ADBLOCK = "1";
    DISABLE_OPENCOLLECTIVE = "1";
    LANG = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
  };
}
