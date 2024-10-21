#!/usr/bin/env bash 
#set -e
##################################################################################################################
# Author 	: ArchN00B
# Website   : https://www.github.com/ArchN00B
##################################################################################################################
#
#   IT'S ALL IN YOUR HANDS
#
##################################################################################################################
#tput setaf 0 = black 
#tput setaf 1 = red 
#tput setaf 2 = green
#tput setaf 3 = yellow 
#tput setaf 4 = dark blue 
#tput setaf 5 = purple
#tput setaf 6 = cyan 
#tput setaf 7 = gray 
#tput setaf 8 = light blue
##################################################################################################################

email=""
username=""
git config --global credential.helper store
git config --global user.email "$email"
git config --global user.name "$username"