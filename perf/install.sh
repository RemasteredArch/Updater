#! /usr/bin/env bash

# SPDX-License-Identifier: GPL-3.0-or-later
#
# Copyright © 2025 RemasteredArch
#
# This file is part of Updater.
#
# Updater is free software: you can redistribute it and/or modify it under the terms of the GNU
# General Public License as published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# Updater is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even
# the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
# Public License for more details.
#
# You should have received a copy of the GNU General Public License along with Updater. If not, see
# <https://www.gnu.org/licenses/>.

set -euo pipefail

announce() {
  reset="\e[0m"
  gray="\e[90m"
  echo -e "$reset$*$reset$gray"
}

script_directory="$(dirname "$(realpath "$0")")"
cd "$script_directory"

command -v docker || {
    echo 'Docker not available!' >&2
    exit 1
}

announce 'Building perf'
sudo docker build --output=. .

announce 'Installing perf'
sudo dpkg -i 'perf.deb'

announce 'Cleaning up'
rm -f ./perf.deb
