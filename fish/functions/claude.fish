function claude --wraps claude
  env \
  -u http_proxy \
  -u https_proxy \
  -u HTTP_PROXY \
  -u HTTPS_PROXY \
  claude --mcp-config ~/.claude/mcp.json $argv
end
