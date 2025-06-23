local wezterm = require 'wezterm'
local mux     = wezterm.mux
local act     = wezterm.action

local config = {}

------------------------------------------------------------
-- general
------------------------------------------------------------

-- config.color_scheme = 'Campbell'
config.font = wezterm.font_with_fallback { 'HackGen Console', 'HackGen' }
config.font_size = 12.0

-- カーソルのスタイル
config.default_cursor_style = 'BlinkingBlock'

-- 常にタブを表示
config.hide_tab_bar_if_only_one_tab = false

-- ウィンドウを閉じるときに確認メッセージを表示しない
config.window_close_confirmation = 'NeverPrompt'

-- tmux の mouse mode に飲まれないための修飾キーを Shift から Ctrl に変更
config.bypass_mouse_reporting_modifiers = 'CTRL'

-- Builtin,System
config.ime_preedit_rendering = 'Builtin'

------------------------------------------------------------
-- domains
------------------------------------------------------------

config.default_domain = 'WSL:fedora(tmux)'

config.wsl_domains = wezterm.default_wsl_domains()
table.insert(config.wsl_domains, {
    name = 'WSL:fedora(fish)',
    distribution = 'fedora',
    default_prog = { 'bash', '--login', '-i', '-c', 'fish' },
})
table.insert(config.wsl_domains, {
    name = 'WSL:fedora(tmux)',
    distribution = 'fedora',
    default_prog = { 'bash', '--login', '-i', '-c', 'tmux' },
})

------------------------------------------------------------
-- key bindings
------------------------------------------------------------

-- config.disable_default_key_bindings = true

config.keys = {
  {
    key    = 'F2',
    action = act.PromptInputLine {
      description = 'Rename Tab',
      action      = wezterm.action_callback(function(window, _pane, line)
        if line then
          window:active_tab():set_title(line)
        end
      end),
    },
  },

  { key = 'v', mods = 'CTRL', action = act.PasteFrom 'Clipboard' },

  -- デフォルトのキーバインドを無効化
  { key = 'Enter', mods = 'ALT', action = act.DisableDefaultAssignment },
  { key = 'LeftArrow',  mods = 'CTRL|SHIFT', action = act.DisableDefaultAssignment  },
  { key = 'RightArrow', mods = 'CTRL|SHIFT', action = act.DisableDefaultAssignment  },
  { key = 'PageUp', mods = 'CTRL', action = act.DisableDefaultAssignment },
  { key = 'PageDown', mods = 'CTRL', action = act.DisableDefaultAssignment },

  -- Shift+Enter で LF を送る (claude code 用)
  { key = 'Enter', mods = 'SHIFT', action = act.SendString '\x0a', },
}

------------------------------------------------------------
-- startup
------------------------------------------------------------
wezterm.on('gui-startup', function(cmd)
  local tab, pane, window = mux.spawn_window(cmd or {})
  window:gui_window():maximize()
end)

return config
