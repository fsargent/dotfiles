# Function to get the current git branch name
function git_current_branch
    git branch --show-current 2>/dev/null
    or git rev-parse --abbrev-ref HEAD 2>/dev/null
end

