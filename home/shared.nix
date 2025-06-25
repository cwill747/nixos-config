{ config, lib, pkgs, inputs, user, homeDir, ... }:

{
  # Import neovim configuration
  imports = [
    ./all/neovim.nix
    ./all/tmux.nix
    ./all/fish.nix
    ./all/mise.nix
    ./all/fonts.nix
  ];

  home.username = user;

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
    pre-commit

    # System monitoring
    htop

    # Terminal enhancements that work across platforms
    bat
    eza  # modern replacement for ls (formerly exa)
    delta  # git diff tool

    mosh

    sqlite

    _1password-cli
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
    aliases = {
      default-branch = "!git symbolic-ref refs/remotes/origin/HEAD | cut -f4 -d/";
      precommit = "diff --cached --diff-algorithm=minimal -w";
      branch-name = "!git rev-parse --abbrev-ref HEAD";
      fb = "!git branch --set-upstream-to=origin/$(git branch-name) $(git branch-name)";
      publish = "!git push -u origin $(git branch-name)";
      recreate = "!f() { [[ -n $@ ]] && git checkout \"$@\" && git unpublish && git checkout master && git branch -D \"$@\" && git checkout -b \"$@\" && git publish; }; f";
      code-review = "difftool origin/develop...";
      merge-span = "!f() { echo $(git log -1 $2 --merges --pretty=format:%P | cut -d' ' -f1)$1$(git log -1 $2 --merges --pretty=format:%P | cut -d' ' -f2); }; f";
      merge-log = "!git log `git merge-span .. $1`";
      merge-diff = "!git diff `git merge-span ... $1`";
      merge-difftool = "!git difftool `git merge-span ... $1`";
      rebase-branch = "!git rebase -i `git merge-base develop HEAD`";
      unstage = "reset HEAD";
      diffc = "diff --cached";
      assume = "update-index --assume-unchanged";
      unassume = "update-index --no-assume-unchanged";
      assumed = "!git ls-files -v | grep ^h | cut -c 3-";
      ours = "!f() { git checkout --ours $@ && git add $@; }; f";
      theirs = "!f() { git checkout --theirs $@ && git add $@; }; f";
      recent = "!git for-each-ref --count=10 --sort=-committerdate refs/heads/ --format='%(refname:short)'";
      overview = "!git log --all --oneline --no-merges";
      diff = "!git diff --word-diff";
      graph = "!git log --graph --oneline --all --decorate --date=iso";
      pushf = "push --force-with-lease";
      root = "rev-parse --show-toplevel";
      bazel = "show -s --date=\"format:%z\" --pretty='format:%C(auto)    commit = \"%H\",%n    shallow_since = \"%at %ad\",' HEAD";
    };
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
