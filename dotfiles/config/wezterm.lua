-- WezTerm configuration

local wezterm = require 'wezterm'

-- Configuration
local config = {}

config.color_scheme = 'Solarized Dark (Gogh)'
config.font = wezterm.font 'Fira Code'
config.font_size = 12.0

-- Window configuration
config.enable_tab_bar = true
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = false
config.hide_tab_bar_if_only_one_tab = true

-- Window size
config.initial_cols = 120
config.initial_rows = 40

-- Keys
config.keys = {
  -- Ctrl+Shift+C for copy
  {key="C", mods="CTRL", action="Copy"},
  -- Ctrl+Shift+V for paste
  {key="V", mods="CTRL", action="Paste"},
  -- Ctrl+Shift+T for new tab
  {key="T", mods="CTRL", action={SpawnTab="CurrentPaneDomain"}},
  -- Ctrl+Shift+W for close tab
  {key="W", mods="CTRL", action={CloseCurrentTab={confirm=true}}},
  -- Ctrl+Shift+N for new window
  {key="N", mods="CTRL", action={SpawnWindow}},
}

-- Mouse
config.enable_scroll_bar = true
config.mouse_bindings = {
  -- Ctrl+Click to open link
  {
    event={Up={streak=1, button='Left'}},
    mods='CTRL',
    action='OpenLinkAtMouseCursor',
  },
}

-- Return configuration
return config