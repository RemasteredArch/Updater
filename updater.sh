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

set -euo pipefail

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

install='false'
case "${1:-''}" in
    -i | --i )
        install='true'
        ;;
esac

# Whether or not to update a program.
should() {
    [ "$install" = 'true' ] && return

    has "$1"
}

github_binary_install() {
    local repo="$1"
    local binary="$2"
    local installed_version="$3"
    local expected_tarball_filename="$4"

    announce "Checking $binary version"

    latest_version="$(
        curl --fail --silent --show-error --location \
            --header 'Accept:application/json' \
            "https://github.com/$repo/releases/latest" \
        | jq --raw-output '.tag_name'
    )"
    local latest_version_no_v=''
    latest_version_no_v="$(echo "$latest_version" | sed 's/^v\(.*\)$/\1/')"

    # I'm intentionally using the input as a formatting string.
    #
    # shellcheck disable=SC2059
    expected_tarball_filename="$(printf "$expected_tarball_filename" "$latest_version_no_v")"

    if [ "$installed_version" == "$latest_version" ]; then
        echo "$binary up to date! ($installed_version)"
        return 0
    fi

    echo "New version of $binary available! ($installed_version => $latest_version)"
    echo -n 'Update? (y/n): '
    read -rn 1 answer
    echo

    [[ "$answer" == 'y' ]] || {
        return 0
    }

    local temp_dir
    temp_dir="$(mktemp --directory)"

    curl --proto '=https' --tlsv1.2 --fail --silent --show-error --location \
        "https://github.com/$repo/releases/download/$latest_version/$expected_tarball_filename" \
        -o "$temp_dir/$expected_tarball_filename"
    tar xf "$temp_dir/$expected_tarball_filename" --directory="$temp_dir"

    cp "$temp_dir/$binary" "$user_binary_dir/$binary"
    chmod u+x "$user_binary_dir/$binary"
}

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

should gradle && {
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

should act && {
    announce 'Checking Act version'

    _act_installed_version=''
    has act && _act_installed_version="v$(act --version | awk '{print $3}')"
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

should git-credential-oauth && {
    _git_credential_installed_version=''
    has git-credential-oauth && {
        _git_credential_installed_version="v$(git-credential-oauth version | awk '{print $2}')"
    }

    github_binary_install \
        'hickford/git-credential-oauth' \
        'git-credential-oauth' \
        "$_git_credential_installed_version" \
        'git-credential-oauth_%s_linux_amd64.tar.gz'

    unset _git_credential_installed_version
}

has docker && {
    announce 'Checking Docker version'

    _docker_installed_version="$(dpkg --list | grep 'docker-ce ' | awk '{ print $3 }')"
    # For some reason, `apt-cache madison docker-ce` cause a pipefail error if output is piped
    # directly into `head`, so it is stored in the variably temporarily.
    #
    # TODO: Use an alternative to `madison`.
    _docker_latest_version="$(apt-cache madison docker-ce)"
    _docker_latest_version="$(echo "$_docker_latest_version" | head -n1 | awk '{ print $3 }')"

    if [ "$_docker_installed_version" != "$_docker_latest_version" ]; then
        echo "New docker version available! ($_docker_installed_version => $_docker_latest_version)"
    else
        echo "Docker up to date! ($_docker_installed_version)"
    fi

    unset _docker_installed_version _docker_latest_version
}
