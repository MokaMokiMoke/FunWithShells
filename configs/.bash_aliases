# Colorful Cat
alias ccat="pygmentize"

# Windows clear feeling
alias cls="clear"

# Make & change directory
mkcd ()
{
    mkdir -p -- "$1" &&
    cd -P -- "$1"    
}

# Easier apt upgrade
alias upgrade="sudo apt update && sudo apt dist-upgrade && sudo apt autoremove"
