function aws-vault
  PATH=(realpath (dirname (realpath (status current-filename)))/../../lib/aws-vault):$PATH command aws-vault $argv
end
