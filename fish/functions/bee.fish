function bee
  if not set -q BACKLOG_SPACE; or test -z "$BACKLOG_SPACE"
    echo "Error: BACKLOG_SPACE is not set." >&2
    return 1
  end

  set -l backlog_api_key (secret-tool lookup service backlog space "$BACKLOG_SPACE")
  if test $status -ne 0; or test -z "$backlog_api_key"
    echo "Error: Backlog API key was not found for space '$BACKLOG_SPACE'." >&2
    echo "Run: secret-tool store --label="(string escape -- "Backlog API key for $BACKLOG_SPACE")" service backlog space "(string escape -- "$BACKLOG_SPACE") >&2
    return 1
  end

  env BACKLOG_API_KEY="$backlog_api_key" bee $argv
end
