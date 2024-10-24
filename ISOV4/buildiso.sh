#!/usr/bin/env bash
set -euo pipefail

# Author: ArchN00B
# Website: https://www.github.com/archn00b

# Logging settings
logfile="/var/log/buildiso.log"
ROOT_UID=0     # Only users with $UID 0 have root privileges.
E_NOTROOT=87   # Non-root exit error.
Profile_Dir="/tmp/archlive"
Rootfs_Dir="${Profile_Dir}/airootfs"
Config_Dir="${Rootfs_Dir}/etc/skel/.config"
Build_Dir="${Profile_Dir}/work"
ISO_Dir="$(basename "$0"/iso)"
archiso_dir="/usr/share/archiso/configs/releng"
packages=("archiso")
add_pkg_file="x86_64.txt"
sddm_service="/usr/lib/systemd/system/sddm.service"
rootfs_service="/etc/systemd/system/display-manager.service"

# Check for root user
check_root() {
    if [ "$UID" -ne "$ROOT_UID" ]; then
        echo -e "\033[31m###################################\033[0m"
        echo "Execute $(basename "$0") as ROOT"
        echo -e "\033[31m###################################\033[0m"
        exit $E_NOTROOT
    fi
}

# Check if a package is installed
check_archiso() {
    pacman -Qi "$1" &> /dev/null
}

# Install packages
install_archiso() {
    echo "Adding ArchIso" | tee -a "$logfile"
    for pkg in "${packages[@]}"; do
        if check_archiso "$pkg"; then
            echo "$pkg is already installed." | tee -a "$logfile"
        else
            echo "Adding $pkg..." | tee -a "$logfile"
            if pacman -S --noconfirm "$pkg" >> "$logfile" 2>&1; then
                echo "$pkg added successfully" | tee -a "$logfile"
            else
                echo "Error installing $pkg..." | tee -a "$logfile"
            fi
        fi
    done
    cp -vr "$archiso_dir/"* "$Profile_Dir" | tee -a "$logfile"
}

# Create directories if they do not exist
check_directories() {
    local dir="$1"
    if [ ! -d "$dir" ]; then
        echo "Directory $dir does not exist. Creating it..."
        mkdir -p "$dir"
    else
        echo "Directory $dir already exists."
    fi
}

# Setup all necessary directories
make_directories() {
    echo "Creating directories..."
    for dir in "$Profile_Dir" "$Rootfs_Dir" "$Config_Dir" "$Build_Dir" "$ISO_Dir"; do
        check_directories "$dir"
    done
}

# Add packages from a file to the package list
add_packages() {
    while IFS= read -r pkg; do
        echo "$pkg" >> "${Profile_Dir}/packages.x86_64"
    done < "$add_pkg_file"
}

# Setup SDDM service
setup_sddm() {
    if [ ! -L "${Rootfs_Dir}/$rootfs_service" ]; then
        ln -s "$sddm_service" "${Rootfs_Dir}/$rootfs_service"
    fi
    cp -r "sddm.conf.d" "/tmp/archlive/airootfs/etc/"
}

# Add AutoLogin liveuser
add_user() {
    local target_dir="${Rootfs_Dir}/etc/"
    
    # Array of directories/files to copy
    local directories=(liveuser/* sudoers.d pam.d profiledef.sh)

    # Copy each item to the target directory
    for dir in "${directories[@]}"; do
        if [[ -e $dir ]]; then
            cp -r "$dir" "$target_dir"
        else
            echo "Warning: $dir does not exist."
        fi
    done
    
    # Copy profiledef.sh to Profile_Dir
    if [[ -e profiledef.sh ]]; then
        cp -r profiledef.sh "${Profile_Dir}"
    else
        echo "Warning: profiledef.sh does not exist."
    fi
}

# Text formatting
bold=$(tput setaf 2 bold)
bolderror=$(tput setaf 3 bold)
normal=$(tput sgr0)

# Function to add ArchN00B core-repo to /etc/pacman.conf
add_repo() {
    printf "%s\n" "${bold}Adding [core-repo] to $Profile_Dir/pacman.conf...${normal}"

    if ! grep -qxF "[core-repo]" "$Profile_Dir"/pacman.conf; then
        {
            echo ""
            echo "[core-repo]"
            echo "SigLevel = Optional TrustAll"
            echo "Server = https://archn00b.github.io/\$repo/\$arch"
        } | sudo tee -a "$Profile_Dir"/pacman.conf
    fi
}

# Create the ISO
make_iso() {
    rm -rf "${Build_Dir:?}/"*  # Delete all contents in the work directory
    mkarchiso -v -w "$Build_Dir" -o "$ISO_Dir" "$Profile_Dir"
}



# Main function to orchestrate the steps
main() {
    check_root
    make_directories
    install_archiso
    add_packages
    setup_sddm
    add_user
    add_repo || { echo "${bolderror}Error adding ArchN00B repo to $Profile_Dir/etc/pacman.conf.${normal}"; exit 1; }
    make_iso
}

# Execute the main function
main
