#!/bin/bash

set -e

GITHUB_RAW_URL="https://raw.githubusercontent.com/weblerson/amigurumi/main"
WAYBAR_DIR="$HOME/waybar"
WALLPAPER_DIR="$HOME/Images"
HYPRPAPER_DIR="$HOME/.config/hypr"

CONFIG_FILE="config.jsonc"
STYLE_FILE="style.css"
WALLPAPER_FILE="w1.png"
HYPRPAPER_FILE="hyprpaper.conf"
HYPRLAND_CONFIG="$HOME/.config/hypr/hyprland.conf"

if [ ! -f "$HYPRLAND_CONFIG" ]; then
    echo "ERROR: Hyprland configuration file not found at $HYPRLAND_CONFIG."
    exit 1
fi

install_package_if_missing() {
    local package_name="$1"

    echo "--- Checking for package: $package_name ---"

    if pacman -Q "$package_name" &>/dev/null; then
        echo "$package_name is already installed. Skipping installation."
    else
        echo "$package_name not found. Installing now..."

        sudo pacman -S --noconfirm "$package_name"

        if [ $? -eq 0 ]; then
            echo "Successfully installed $package_name."
        else
            echo "ERROR: Failed to install $package_name. Check pacman repositories or user permissions."
            exit 1
        fi
    fi
}

echo "--- Checking required packages ---\n"

install_package_if_missing "hyprpaper"

echo "--- Package checks complete! ---\n"

echo "--- Checking directories ---\n"

if [ ! -d $WAYBAR_DIR ]; then
echo "Waybar base directory not found. Creating it."
  mkdir -p $WAYBAR_DIR
fi

if [ ! -d $WALLPAPER_DIR ]; then
  echo "Wallpaper directory not found. Creating it"
  mkdir -p $WALLPAPER_DIR
fi

echo "--- Directory checks complete! ---\n"

echo "--- Checking files ---"

download_if_missing() {
    local filename="$1"
    local dest_dir="$2"
    local full_path="$dest_dir/$filename"
    local full_url="$GITHUB_RAW_URL/$filename"

    echo "--- Checking $filename in $dest_dir ---"

    if [ ! -f "$full_path" ]; then
        echo "$filename not found. Downloading from $full_url..."
        curl -sSL "$full_url" -o "$full_path"

        if [ $? -eq 0 ]; then
            echo "Successfully downloaded $filename."
        else
            echo "ERROR: Failed to download $filename."
            exit 1
        fi
    else
        echo "$filename already exists. Skipping download."
    fi
}

download_if_missing "$STYLE_FILE" "$WAYBAR_DIR"
download_if_missing "$CONFIG_FILE" "$WAYBAR_DIR"

download_if_missing "$WALLPAPER_FILE" "$WALLPAPER_DIR"
download_if_missing "$HYPRPAPER_FILE" "$HYPRPAPER_DIR"

echo "--- File checks complete! ---"

LINE_TO_APPEND="exec-once = waybar -c $HOME/waybar/config.jsonc -s $HOME/waybar/style.css & hyprpaper"

if grep -qF "$LINE_TO_APPEND" "$HYPRLAND_CONFIG"; then
    echo "The waybar/hyprpaper 'exec-once' line is already present. Skipping append."
else
    echo "Appending the waybar/hyprpaper 'exec-once' line..."

    echo "" >> "$HYPRLAND_CONFIG"
    echo "$LINE_TO_APPEND" >> "$HYPRLAND_CONFIG"

    echo "Successfully appended command to $HYPRLAND_CONFIG."
fi
