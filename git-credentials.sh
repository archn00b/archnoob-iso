#!/usr/bin/env bash
set -euo pipefail

##################################################################################################################
# Author 	: ArchN00B
# Website   : https://www.github.com/ArchN00B
##################################################################################################################
#
#   IT'S ALL IN YOUR HANDS
#
##################################################################################################################

# Function to validate email format
is_valid_email() {
    [[ "$1" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]
}

# Function to prompt for user input if not provided as an argument
prompt_for_input() {
    local prompt_message="$1"
    read -rp "$prompt_message: " input
    echo "$input"
}

# Main function to set up Git configuration
setup_git_config() {
    local email username

    # Check command-line arguments
    if [[ -n "${1:-}" ]] && is_valid_email "$1"; then
        email="$1"
    else
        email=$(prompt_for_input "Enter your Git email")
        while ! is_valid_email "$email"; do
            echo "Invalid email format. Please try again."
            email=$(prompt_for_input "Enter your Git email")
        done
    fi

    if [[ -n "${2:-}" ]] && [[ -n "$2" ]]; then
        username="$2"
    else
        username=$(prompt_for_input "Enter your Git username")
        while [[ -z "$username" ]]; do
            echo "Username cannot be empty. Please try again."
            username=$(prompt_for_input "Enter your Git username")
        done
    fi

    git config --global credential.helper store
    git config --global user.email "$email"
    git config --global user.name "$username"

    echo "Git configuration has been set up successfully."
}

# Execute the main function with command-line arguments
setup_git_config "$@"
