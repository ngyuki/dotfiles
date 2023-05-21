function fish_user_key_bindings

  bind \cr __fzf_reverse_isearch
  bind \ct __fzf_find_file
  bind \ch __oreore_fzf_hostnames

  # https://github.com/fish-shell/fish-shell/issues/217
  # ctrl+m == CR == enter
  # ctrl+j == LF == ctrl+enter

  # \cj や \cm をバインドすると xpanes の動作がおかしくなる
  # bind \cj __oreore_exec

  bind -k ppage history-search-backward
  bind -k npage history-search-forward

  #bind \t complete
  bind \t '__fzf_complete'
  #bind \t '__oreore_fzf_complete'

  bind -k btab complete-and-search

  bind \cx\ce edit_command_buffer

  bind \cq 'commandline -f repaint'
end
