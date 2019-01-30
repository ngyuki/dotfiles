function fish_user_key_bindings

  bind \cr __fzf_history
  bind \cf __fzf_find
  bind \ch __fzf_hostnames

  bind -k ppage history-search-backward
  bind -k npage history-search-forward

  bind \t '__fzf_complete'

end
