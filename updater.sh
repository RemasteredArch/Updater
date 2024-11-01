#! /bin/env bash

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

text_reset='\e[0m'
text_bold='\e[97m\e[100m\e[1m' # Bold white text on a gray background

announce() {
    echo -e "\n$text_reset$text_bold$*$text_reset"
}

# Detect if a program or alias exists
has() {
  [ "$(type "$1" 2> /dev/null)" ]
}

directory=$(dirname "$0")
user_binary_dir="$HOME/.local/bin"

has tldr && {
    announce 'Updating tldr cache...'
    # Adds support for customizable tldr update script to account for variations in tldr
    # implementation
    if [ -e "$directory/tldr_update.sh" ]; then
        "$directory/tldr_update.sh"
    else
        tldr -u # Fallback
    fi
}

has snap && {
    announce 'Updating Snaps...'
    sudo snap refresh
}

has apt && {
    announce 'Updating apt packages...'
    sudo apt update && sudo apt upgrade
}

has gradle && {
    announce 'Updating Gradle...'
    "$directory/gradle_update.sh"
}

has bun && {
    announce 'Updating Bun'
    bun upgrade
}

has rustup && {
    announce 'Updating Rust...'
    rustup upgrade
}

has cargo-install-update && {
    announce 'Updating Rust packages...'
    cargo install-update --all
}

has act && {
    announce 'Checking Act version'

    _act_installed_version="v$(act --version | awk '{print $3}')"
    _act_latest_version="$(
        curl --fail --silent --show-error --location \
            --header 'Accept:application/json' \
            'https://github.com/nektos/act/releases/latest' \
         | jq --raw-output '.tag_name'
    )"

    if [ "$_act_installed_version" != "$_act_latest_version" ]; then
        echo "New version of Act available! ($_act_installed_version => $_act_latest_version)"
        echo -n 'Update? (y/n): '
        read -rn 1 answer
        echo

        [[ "$answer" == "y" ]] && {
            temp_file="$(mktemp)"
            curl --proto '=https' --tlsv1.2 --fail --silent --show-error --location \
                'https://raw.githubusercontent.com/nektos/act/master/install.sh' \
                -o "$temp_file"
            chmod u+x "$temp_file"
            "$temp_file" -b "$user_binary_dir"
            rm "$temp_file"
            unset temp_file
        }
    else
        echo "Act up to date! ($_act_installed_version)"
    fi

    unset _act_installed_version _act_latest_version
}

has docker && {
    announce 'Checking Docker version'

    _docker_installed_version="$(dpkg --list | grep 'docker-ce ' | awk '{print $3}')"
    _docker_latest_version="$(apt-cache madison docker-ce | head -1 | awk '{ print $3 }')"

    if [ "$_docker_installed_version" != "$_docker_latest_version" ]; then
        echo "New docker version available! ($_docker_installed_version => $_docker_latest_version)"
    else
        echo "Docker up to date! ($_docker_installed_version)"
    fi

    unset _docker_installed_version _docker_latest_version
}
