{ config, lib, pkgs, ... }:

{
  # Import neovim configuration
  imports = [
    ./all/neovim.nix
    ./all/tmux.nix
    ./all/fish.nix
  ];

  # Basic home-manager settings
  home.stateVersion = "24.05";

  # Let home-manager manage itself
  programs.home-manager.enable = true;

  # Additional programs and packages
  home.packages = with pkgs; [
    # Essential development tools
    git
    curl
    wget
    jq

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
