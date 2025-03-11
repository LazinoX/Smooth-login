#!/bin/bash

# Ensure the script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

# Define paths
GRUB_D_DIR="/etc/grub.d"
MKINITCPIO_CONF="/etc/mkinitcpio.conf"
GRUB_DEFAULT="/etc/default/grub"
REPO_URL="https://github.com/LazinoX/Smooth-login.git"
TEMP_DIR="$(mktemp -d)"

# Delete existing files
echo "Deleting existing files..."
rm -f "$GRUB_D_DIR/10_linux" "$MKINITCPIO_CONF" "$GRUB_DEFAULT"

# Clone the repository
echo "Cloning repository..."
git clone --depth=1 "$REPO_URL" "$TEMP_DIR"

# Copy new files
echo "Copying new files..."
cp "$TEMP_DIR/10_linux" "$GRUB_D_DIR/"
cp "$TEMP_DIR/mkinitcpio.conf" "/etc/"
cp "$TEMP_DIR/grub" "$GRUB_DEFAULT"

# Clean up
echo "Cleaning up..."
rm -rf "$TEMP_DIR"

echo "Done! Files have been replaced successfully."
