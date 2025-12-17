# Git Checkout Interactive function that works regardless of current directory's mise environment
function gci
    # Use mise exec to run gci with the correct node environment
    # This will use the node version from your global mise config or a .tool-versions file
    mise exec node@latest -- npx git-checkout-interactive $argv
end

