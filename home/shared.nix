{ config, lib, pkgs, ... }:

{
  # Import neovim configuration
  imports = [
    ./all/neovim.nix
    ./all/tmux.nix
    ./all/fish.nix
  ];

  home.username = "cameron";
  home.homeDirectory = "/home/cameron";

  # Basic home-manager settings
  home.stateVersion = "24.05";

  # Let home-manager manage itself
  programs.home-manager.enable = true;

  # Additional programs and packages
  home.packages = with pkgs; [
    # Essential development tools
    git
    git-lfs
    curl
    wget
    jq
    delta
    yq
    go
    nodejs
    yarn
    python3Full

    tree-sitter
    # File management and search
    fd
    ripgrep
    fzf
    tree

    # Development tools
    direnv
    mise

    # System monitoring
    htop

    # Terminal enhancements that work across platforms
    bat
    eza  # modern replacement for ls (formerly exa)
    delta  # git diff tool

    mosh

    sqlite

    _1password-cli
    postman
    powershell
    wireshark  # GUI version (CLI already included elsewhere)

    bazel-buildtools
    bazelisk
  ];

  # Git configuration
  programs.git = {
    enable = true;
    # These can be overridden per-host if needed
    userName = lib.mkDefault "Cameron Will";
    userEmail = lib.mkDefault "stephen.will@tanium.com";  # Work email (overridden on personal mac)

    extraConfig = {
      init.defaultBranch = "main";
      push.default = "current";
      pull.rebase = true;
    };
    lfs.enable = true;
  };

  # Direnv integration
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # FZF configuration
  programs.fzf = {
    enable = true;
    defaultCommand = "fd --type f";
    fileWidgetCommand = "fd --type f";
    changeDirWidgetCommand = "fd --type d";
  };

  # Neovim configuration is imported from ./neovim.nix
}
