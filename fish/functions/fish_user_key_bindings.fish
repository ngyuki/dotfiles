function fish_user_key_bindings

  bind \cr __fzf_history
  bind \cf __fzf_find
  bind \ch __fzf_hostnames

  # https://github.com/fish-shell/fish-shell/issues/217
  # ctrl+m == CR == enter
  # ctrl+j == LF == ctrl+enter

  # \cj や \cm をバインドすると xpanes の動作がおかしくなる
  # bind \cj __dotfiles_exec

  bind -k ppage history-search-backward
  bind -k npage history-search-forward

  bind \t complete
  bind -k btab complete-and-search
  #bind \t '__fzf_complete'

  bind \cx\ce edit_command_buffer

  bind \cq 'commandline -f repaint'
end
