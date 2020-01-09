function fish_user_key_bindings

  bind \cr __fzf_history
  bind \cf __fzf_find
  bind \ch __fzf_hostnames

  bind \cj __dotfiles_exec

  bind -k ppage history-search-backward
  bind -k npage history-search-forward

  #bind \t complete
  #bind -k btab complete-and-search
  bind \t '__fzf_complete'
  bind -k btab 'commandline -f repaint'

end
