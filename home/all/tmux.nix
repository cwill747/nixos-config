{ pkgs, config, ... }:
{
  programs.tmux = {
    enable = true;
    shortcut = "b";
    # aggressiveResize = true; -- Disabled to be iTerm-friendly
    baseIndex = 1;
    newSession = true;
    # Stop tmux+escape craziness.
    escapeTime = 0;

    plugins = with pkgs; [
      tmuxPlugins.better-mouse-mode
      tmuxPlugins.sensible
      tmuxPlugins.resurrect
      tmuxPlugins.continuum
      tmuxPlugins.yank
    ];

    extraConfig = ''
      # https://old.reddit.com/r/tmux/comments/mesrci/tmux_2_doesnt_seem_to_use_256_colors/
      set -g default-terminal "xterm-256color"
      set -ga terminal-overrides ",*256col*:Tc"
      set -ga terminal-overrides '*:Ss=\E[%p1%d q:Se=\E[ q'
      set-environment -g COLORTERM "truecolor"

      # Mouse works as expected
      set-option -g mouse on
      # easy-to-remember split pane commands
      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"

      # index of 0 for windows and panes
      set -g base-index 0
      setw -g pane-base-index 0

      # mmemonic keys for window splitting
      bind | split-window -h
      bind - split-window -v

      # vim movement keys for switching panes
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R

      # vim movement keys for switching windows
      bind -r C-h select-window -t :-
      bind -r C-l select-window -t :+

      # vim movement keys for resizing panes
      bind -r H resize-pane -L 5
      bind -r J resize-pane -D 5
      bind -r K resize-pane -U 5
      bind -r L resize-pane -R 5

      setw -g mode-keys vi
      set-option -g set-titles on
      set-option -g set-titles-string "#S / #W"
    '';
  };
}