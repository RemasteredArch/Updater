#! /usr/bin/env bash

# SPDX-License-Identifier: GPL-3.0-or-later
#
# Copyright © 2024 RemasteredArch
#
# This file is part of Updater.
#
# Updater is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
#
# Updater is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with Updater. If not, see <https://www.gnu.org/licenses/>.

GRADLE_USER_HOME="${GRADLE_USER_HOME:-"$HOME/.gradle"}"

install_directory="$GRADLE_USER_HOME/install"

bin_dir="$HOME/.local/bin"

script_directory="$(dirname "$(realpath "$0")")"

announce() {
  reset="\e[0m"
  #bold="\e[1m"
  bold="\e[0m" # disables bold output
  gray="\e[90m"
  echo -e "$reset$bold$*$reset$gray"
}

if [ -r "$script_directory/gradle_lock" ]; then
  announce "Checking latest version from gradle_lock..."
  current_version=$(cat "$script_directory/gradle_lock")
else
  announce "Checking latest version from online..."
  api=$(curl "https://services.gradle.org/versions/current" --silent)
  current_version=$(echo "$api" | jq .version --raw-output)
fi

announce "Checking installed version..."
is_installed=$(command -v gradle 2> /dev/null)

install_gradle() {
  [ -d "$install_directory" ] && {
    announce "Removing existing directory..."
    rm -r "$install_directory"
  }

  announce "Getting ready..."

  mkdir -p "$install_directory"

  cd "$install_directory" || exit

  if [ -r "$script_directory/gradle_lock" ]; then
    download_url="https://services.gradle.org/distributions/gradle-$current_version-bin.zip"
  else
    download_url=$(echo "$api" | jq .downloadUrl --raw-output)
  fi

  announce "Downloading..."

  wget "$download_url" --no-verbose

  announce "Unzipping..."

  unzip -q ./gradle*.zip

  announce "Cleaning up zip..."

  rm ./gradle*.zip

  announce "Installing to $install_directory..."

  dir=$(ls)

  mv "$dir"/* .

  announce "Cleaning up..."

  rmdir "$dir"

  announce "Adding symlink to $HOME/.local/bin..."

  [ ! -d "$bin_dir" ] && mkdir -p "$HOME/.local/bin/"

  symlink="$bin_dir/gradle"

  [ -e "$symlink" ] && rm "$symlink"

  ln -s "$install_directory/bin/gradle" "$symlink"

  echo -e "\e[0mAll done! Don't forget to add ~/.local/bin to \$PATH if it isn't yet."

  exit
}

[ -z "$is_installed" ] && {
  announce "No version of Gradle detected! Install now? (y/n):"

  read -rn 1 answer
  echo

  [[ "$answer" == "y" ]] && install_gradle
  exit
}

installed_version=$(gradle --version | grep "Gradle" | grep --only-matching "[0-9]\.[0-9]" 2> /dev/null)

[[ $current_version > $installed_version ]] && {
  announce "Currently installed version is out of date ($installed_version vs $current_version). Update? (y/n)"

  read -rn 1 answer
  echo

  [[ "$answer" == "y" ]] && install_gradle
  exit
}

announce "Gradle is up to date! ($installed_version == $current_version)"

