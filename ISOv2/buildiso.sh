#!/usr/bin/env bash
set -euo pipefail
##################################################################################################################
# Author 	: ArchN00B
# Website   : https://www.github.com/archn00b
######################################################################################
#
#   ITS ALL IN YOUR HANDS. READ & OBSERVE SCRIPT ESPECIALLY COMMENTS
#
######################################################################################
# PRINTING COLORS TO THE COMMAND LINE CHOOSE EITHER SYLE
######################################################################################################################################################
# tput setaf 0 = black 
# tput setaf 1 = red 
# tput setaf 2 = green
# tput setaf 3 = yellow 
# tput setaf 4 = dark blue 
# tput setaf 5 = purple
# tput setaf 6 = cyan 
# tput setaf 7 = gray 
# tput setaf 8 = light blue
# tput sgr0 = default
# printf "|039| \033[39mDefault \033[m  |049| \033[49mDefault \033[m  |037| \033[37mLight gray \033[m     |047| \033[47mLight gray \033[m\n"
# printf "|030| \033[30mBlack \033[m    |040| \033[40mBlack \033[m    |090| \033[90mDark gray \033[m      |100| \033[100mDark gray \033[m\n"
# printf "|031| \033[31mRed \033[m      |041| \033[41mRed \033[m      |091| \033[91mLight red \033[m      |101| \033[101mLight red \033[m\n"
# printf "|032| \033[32mGreen \033[m    |042| \033[42mGreen \033[m    |092| \033[92mLight green \033[m    |102| \033[102mLight green \033[m\n"
# printf "|033| \033[33mYellow \033[m   |043| \033[43mYellow \033[m   |093| \033[93mLight yellow \033[m   |103| \033[103mLight yellow \033[m\n"
# printf "|034| \033[34mBlue \033[m     |044| \033[44mBlue \033[m     |094| \033[94mLight blue \033[m     |104| \033[104mLight blue \033[m\n"
# printf "|035| \033[35mMagenta \033[m  |045| \033[45mMagenta \033[m  |095| \033[95mLight magenta \033[m  |105| \033[105mLight magenta \033[m\n"
# printf "|036| \033[36mCyan \033[m     |046| \033[46mCyan \033[m     |096| \033[96mLight cyan \033[m     |106| \033[106mLight cyan \033[m\n"
######################################################################################################################################################

# SETTINGS VARIABLES
export logfile="/var/log/buildiso.log"
export ROOT_UID=0     # Only users with $UID 0 have root privileges.
export E_NOTROOT=87   # Non-root exit error.
export Profile_Dir="/tmp/archlive"
export Rootfs_Dir="${Profile_Dir}/airootfs"
export Config_Dir="${Rootfs_Dir}/etc/skell/.config"
export Build_Dir="${Profile_Dir}/work"
ISO_Dir="$(basename "$0"/iso)"
export archiso_dir="/usr/share/archiso/configs/releng"
export packages=("archiso")
add_pkg_file="x86_64.txt"

# Run as root, of course.
Root(){
  if [ "$UID" -ne "$ROOT_UID" ]
     then
     tput setaf 1
     echo "###################################"
     echo "Execute $(basename "$0" ) as ROOT              "
     echo "###################################"
     tput sgr0
     echo ""
     exit $E_NOTROOT
 fi
}

pgk_is_installed() {
	pacman -Qi "$1" &> /dev/null
}

install_packages() {
	echo "Adding packages..." | tee -a "$logfile"
	for pkg in "${packages[@]}"; do
	    if pgk_is_installed "$pkg"; then
		   tput setaf 1
	       echo "$pkg is already installed." | tee -a "$logfile"
		   echo ""
		   tput sgr0
	else
	       echo "Adding $pkg..." | tee -a "$logfile"
	       if ! install_packages; then
		   echo "$pkg added successfully" | tee -a "$logfile"
	       else
		   echo "Error installing $pkg..." | tee -a "$logfile"
	       fi
             fi
            cp -vr $archiso_dir/* $Profile_Dir >> "$logfile"
	  done 
}

 # Function to check and create directories
check_and_create_dir() {
    local dir="$1"
    if [ ! -d "$dir" ]; then
        echo "Directory $dir does not exist. Creating it..."
        mkdir -p "$dir"
    else
        echo "Directory $dir already exists."
    fi
}

# Function to set up directories
setup_directories() {
    echo "Setting up directories..."
    check_and_create_dir "$Profile_Dir"
    check_and_create_dir "$Rootfs_Dir"
    check_and_create_dir "$Config_Dir"
    check_and_create_dir "$Build_Dir"
    check_and_create_dir "$ISO_Dir"
}
# Adding packages to packages.x86_64
source addpkg.sh

# Deleting all contents in work direcrory executing mkarchiso
make_iso() {
    [[ -d $Build_Dir ]]; rm -rf "${Build_Dir:?}/"*;  mkarchiso -v -w $Build_Dir -o "$ISO_Dir" $Profile_Dir
}

# Main function
main() {
    Root
    setup_directories
    install_packages
    add_pkg
    make_iso
}

# Run the main function
main





