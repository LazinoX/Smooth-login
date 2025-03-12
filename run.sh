bash <(cat << 'EOF'
#!/bin/bash

# Variables
DOWNLOAD_DIR="$HOME/Smooth-login"  # Uses the current user's home directory
GRUB_10_LINUX="/etc/grub.d/10_linux"
MKINITCPIO_CONF="/etc/mkinitcpio.conf"
GRUB_DEFAULT="/etc/default/grub"

# Pacman-style animation
pacman_animation() {
    local i=0
    while :; do
        for ((i = 0; i < 4; i++)); do
            printf "\r%s Pacman is working... [%s]" "$1" "${frames[i]}"
            sleep 0.2
        done
    done
}

# Progress bar
progress_bar() {
    local duration=${1}
    local bar_length=50
    local sleep_interval=$(awk "BEGIN {print $duration/$bar_length}")
    for ((i = 0; i <= bar_length; i++)); do
        printf "\r[%-${bar_length}s] %d%%" "$(printf '#%.0s' $(seq 1 $i))" "$((i * 100 / bar_length))"
        sleep "$sleep_interval"
    done
    printf "\n"
}

# Frames for Pacman animation
frames=("◐" "◓" "◑" "◒")

# Install dependencies
echo "Installing dependencies..."
pacman_animation "Installing" &
animation_pid=$!
sudo pacman -S --noconfirm bc > /dev/null 2>&1
kill "$animation_pid"
printf "\rInstalling dependencies... Done!\n"

# Check if the Smooth-login folder exists
if [ ! -d "$DOWNLOAD_DIR" ]; then
    echo "Smooth-login folder not found. Exiting."
    exit 1
fi

# Backup original files
echo "Backing up original files..."
pacman_animation "Backing up" &
animation_pid=$!
sudo cp "$GRUB_10_LINUX" "$GRUB_10_LINUX.bak" > /dev/null 2>&1
sudo cp "$MKINITCPIO_CONF" "$MKINITCPIO_CONF.bak" > /dev/null 2>&1
sudo cp "$GRUB_DEFAULT" "$GRUB_DEFAULT.bak" > /dev/null 2>&1
kill "$animation_pid"
printf "\rBacking up original files... Done!\n"

# Delete the specified files
echo "Deleting existing files..."
pacman_animation "Deleting" &
animation_pid=$!
sudo rm -f "$GRUB_10_LINUX" "$MKINITCPIO_CONF" "$GRUB_DEFAULT" > /dev/null 2>&1
kill "$animation_pid"
printf "\rDeleting existing files... Done!\n"

# Copy the new files from the Smooth-login folder
echo "Copying new files..."
pacman_animation "Copying" &
animation_pid=$!
sudo cp "$DOWNLOAD_DIR/10_linux" "/etc/grub.d/" > /dev/null 2>&1
sudo cp "$DOWNLOAD_DIR/mkinitcpio.conf" "/etc/" > /dev/null 2>&1
sudo cp "$DOWNLOAD_DIR/grub" "/etc/default/" > /dev/null 2>&1
kill "$animation_pid"
printf "\rCopying new files... Done!\n"

# Check if the files were copied successfully
if [ ! -f "/etc/grub.d/10_linux" ] || [ ! -f "/etc/mkinitcpio.conf" ] || [ ! -f "/etc/default/grub" ]; then
    echo "Failed to copy files. Exiting."
    exit 1
fi

# Execute grub-mkconfig and mkinitcpio
echo "Regenerating GRUB configuration..."
progress_bar 2  # Simulate a 2-second progress bar
sudo grub-mkconfig -o /boot/grub/grub.cfg > /dev/null 2>&1
echo "Regenerating initramfs..."
progress_bar 2  # Simulate a 2-second progress bar
sudo mkinitcpio -P > /dev/null 2>&1

# Cleanup: Delete the Smooth-login folder
echo "Cleaning up..."
if [ -d "$DOWNLOAD_DIR" ]; then
    rm -rf "$DOWNLOAD_DIR"
    echo "Smooth-login folder deleted."
else
    echo "Smooth-login folder not found. Skipping cleanup."
fi

echo "Script completed successfully."
EOF
)
