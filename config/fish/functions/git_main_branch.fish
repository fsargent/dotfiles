# Function to determine the default git branch name
function git_main_branch
    if git branch --list main | string match -q '*main*'
        echo main
    else
        echo master
    end
end

