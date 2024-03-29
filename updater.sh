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

text_reset="\e[0m"
text_bold="\e[97m\e[100m\e[1m" # bold white text on a gray background

announce() {
	echo -e "\n$text_reset$text_bold$@$text_reset"
}

directory=$(dirname $0)

announce Updating tldr cache...
if [[ -e "$directory/tldr_update.sh" ]]; then
	"$directory/tldr_update.sh" # add support for customizable tldr update script to account for variantions in tldr implementation
else
	tldr -u # fallback
fi

announce Updating Snaps...
sudo snap refresh

announce Updating apt packages...
sudo apt update && sudo apt upgrade

announce Updating Gradle...
"$directory/gradle_update.sh"

announce Updating Rust...
rustup upgrade

echo -e "$text_reset"
