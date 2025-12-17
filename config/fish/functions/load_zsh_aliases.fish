# Function to load aliases from zsh aliases file
function load_zsh_aliases
    set -l aliases_file ~/.config/zsh/.aliases
    
    if not test -f "$aliases_file"
        return 0
    end
    
    # Read the aliases file and convert simple aliases
    while read -r line || test -n "$line"
        # Skip comments, empty lines, and function definitions
        if string match -qr '^\s*(#|function|add-alias)' "$line"
            continue
        end
        
        # Match alias definitions: alias name='command' or alias name="command"
        if string match -qr "^alias\s+([^=]+)=(.+)$" "$line"
            set -l match_result (string match -r "^alias\s+([^=]+)=(.+)$" "$line")
            set -l alias_name (string trim $match_result[2])
            set -l alias_cmd (string trim $match_result[3])
            
            # Remove quotes if present
            set alias_cmd (string replace -r "^['\"](.*)['\"]$" '$1' "$alias_cmd")
            
            # Skip aliases that use functions that don't exist in fish
            if string match -qr '\$\(git_current_branch\)|_git_log_prettily' "$alias_cmd"
                continue
            end
            
            # Convert backticks to fish command substitution where simple
            # For complex cases, we'll skip them
            if string match -qr '`.*`' "$alias_cmd"
                # Skip complex command substitutions for now
                # These would need manual conversion
                continue
            end
            
            # Convert $(command) to (command) for fish
            set alias_cmd (string replace -r '\$\(([^)]+)\)' '($1)' "$alias_cmd")
            
            # Create the alias
            alias $alias_name="$alias_cmd"
        end
    end < "$aliases_file"
end

