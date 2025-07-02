{ pkgs, ... }:

{
  programs.wezterm = {
    enable = true;
    extraConfig = ''
      local wezterm = require 'wezterm'

      local function is_dark()
        if wezterm.gui then
          return wezterm.gui.get_appearance():find("Dark")
        end
        return true
      end

      local config = wezterm.config_builder()

      if is_dark() then
        config.color_scheme = 'Gruvbox Dark (Gogh)'
      else
        config.color_scheme = 'GruvboxLight'
      end

      wezterm.on('update-status', function(window)
        local SOLID_LEFT_ARROW = utf8.char(0xe0b2)
        local color_scheme = window:effective_config().resolved_palette
        local bg = color_scheme.background
        local fg = color_scheme.foreground

        window:set_right_status(wezterm.format({
          { Background = { Color = 'none' } },
          { Foreground = { Color = bg } },
          { Text = SOLID_LEFT_ARROW },
          { Background = { Color = bg } },
          { Foreground = { Color = fg } },
          { Text = ' ' .. wezterm.hostname() .. ' ' },
        }))
      end)

      config.leader = { key = 'a', mods = 'CTRL', timeout_milliseconds = 1000 }

      local function move_pane(key, direction)
        return {
          key = key,
          mods = 'LEADER',
          action = wezterm.action.ActivatePaneDirection(direction),
        }
      end

      config.keys = {
        {
          key = '"',
          mods = 'LEADER',
          action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' },
        },
        {
          key = '%',
          mods = 'LEADER',
          action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' },
        },
        {
          key = 'a',
          mods = 'LEADER|CTRL',
          action = wezterm.action.SendKey { key = 'a', mods = 'CTRL' },
        },
        move_pane('j', 'Down'),
        move_pane('k', 'Up'),
        move_pane('h', 'Left'),
        move_pane('l', 'Right'),
      }

      config.font = wezterm.font('TX-02')

      local success, ssh_config = pcall(require, 'ssh')
      if success then
        config.ssh_domains = ssh_config.ssh_domains
      end

      return config
    '';
  };
}