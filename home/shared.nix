{ config, lib, pkgs, ... }:

{
  # Import neovim configuration
  imports = [
    ./neovim.nix
  ];

  # Basic home-manager settings
  home.stateVersion = "24.05";

  # Let home-manager manage itself
  programs.home-manager.enable = true;

  # Fish shell configuration
  programs.fish = {
    enable = true;

    # Fish shell configuration based on the provided config
    shellInit = ''
      set -gx fish_greeting ""

      # Fish git prompt settings
      set __fish_git_prompt_showdirtystate 'yes'
      set __fish_git_prompt_showstashstate 'yes'
      set __fish_git_prompt_showuntrackedfiles 'yes'
      set __fish_git_prompt_showupstream 'yes'
      set __fish_git_prompt_color_branch yellow
      set __fish_git_prompt_color_upstream_ahead green
      set __fish_git_prompt_color_upstream_behind red

      # Status chars
      set __fish_git_prompt_char_upstream_behind '↓'
      set __fish_git_prompt_char_upstream_ahead '↑'

      # Environment variables
      set -x LANG "en_US.UTF-8"
      set -x LC_ALL "en_US.UTF-8"
      set -x EDITOR "nvim"

      # FZF configuration
      set -x FZF_DEFAULT_COMMAND 'fd --type f'
      set -x FZF_CTRL_T_COMMAND $FZF_DEFAULT_COMMAND

      # Disable annoying npm/node spam
      set -x DISABLE_OPENCOLLECTIVE 1
      set -x ADBLOCK 1

      # Pure prompt settings
      set --universal pure_check_for_new_release false
      set --universal pure_enable_single_line_prompt true
      set --universal pure_show_jobs true
      set -g async_prompt_functions _pure_prompt_git

      # pnpm setup
      set -gx PNPM_HOME "$HOME/.local/share/pnpm"
      if test -d $PNPM_HOME
        if not string match -q -- $PNPM_HOME $PATH
          set -gx PATH "$PNPM_HOME" $PATH
        end
      end

      set -gx __fish_initialized 1
    '';

    # Shell aliases from the provided aliases.fish
    shellAliases = {
      # Editor aliases
      "vim" = "nvim";
      "vi" = "nvim";
      "oldvim" = "\\vim";

      # Config editing aliases
      "ev" = "vim ~/.config/nvim/init.vim";
      "ea" = "vim ~/.config/fish/aliases.fish";
      "ef" = "vim ~/.config/fish/config.fish";

      # SSH with proper terminal
      "ssh" = "TERM=xterm-256color /usr/bin/ssh";

      # Tool aliases
      "asdf" = "mise";
      "rtx" = "mise";
      "yadm" = "chezmoi";
    };

    # Fish functions - translate key functions from the provided config
    functions = {
      # Clean Python cache files
      cleanpycs = {
        body = ''
          find . -name '.git' -prune -o -name '__pycache__' -delete
          find . -name '.git' -prune -o -name '*.py[co]' -delete
        '';
        description = "Clean Python cache files";
      };

      # Go to git root
      gr = {
        body = "cd (git root)";
        description = "Go to git repository root";
      };

      # Create temporary directory and cd into it
      t = {
        body = "pushd (mktemp -d /tmp/$argv[1].XXXX)";
        description = "Create and enter temporary directory";
      };

      # Git cleanup function
      varga = {
        body = ''
          git remote prune origin
          set before (git branch -vv | wc -l)
          git branch -vv | grep 'gone]' | awk '{ print $1}' | xargs git branch -D
          set after (git branch -vv | wc -l)
          set removed (math $before - $after)
          if [ $removed = 0 ]
              echo "I have removed no branches.  Why do I exist? ¯\\_(ツ)_/¯"
          else
              echo "I have removed $removed branches.  I did good work today"
          end
        '';
        description = "Clean up merged git branches";
      };

      # Download file to temp directory
      gf = {
        argumentNames = [ "url" ];
        body = ''
          if test (count $url) -eq 0
            echo "Error: No URL provided."
            return 1
          end

          set tempdir (mktemp -d /tmp/$argv[1].XXXX)
          if test $status -ne 0
            echo "Error: Failed to create temp directory"
            return 1
          end

          set filename (basename "$url")
          set output "$tempdir/$filename"

          curl -s -L -o $output $url
          if test $status -ne 0
            echo "Error: failed to download file"
            return 1
          end

          echo $output
        '';
        description = "Download file to temporary location";
      };
    };

    # Fish plugins - temporarily disabled due to build issues
    plugins = [
      {
        # https://github.com/lilyball/nix-env.fish
        name = "nix-env.fish";
        src = pkgs.fetchFromGitHub {
          owner = "lilyball";
          repo = "nix-env.fish";
          rev = "7b65bd228429e852c8fdfa07601159130a818cfa";
          sha256 = "069ybzdj29s320wzdyxqjhmpm9ir5815yx6n522adav0z2nz8vs4";
        };
      }
      {
        name = "fzf-fish";
        src = pkgs.fishPlugins.grc.src;
      }
      {
        name = "z";
        src = pkgs.fishPlugins.z.src;
      }
      {
        name = "pure";
        src = pkgs.fishPlugins.pure.src;
      }
      {
        name = "async-prompt";
        src = pkgs.fishPlugins.async-prompt.src;
      }
    ];
  };

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
    grc # needed by fzf-fish
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
