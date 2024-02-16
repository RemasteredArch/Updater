#! /bin/env bash

# This file is part of Updater.
#
# Updater is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
#
# Updater is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with Updater. If not, see <https://www.gnu.org/licenses/>.

if [[ -z $GRADLE_USER_HOME ]]; then
	GRADLE_USER_HOME=$HOME/.gradle
fi
install_directory="$GRADLE_USER_HOME/install"

bin_dir="$HOME/.local/bin"

announce() {
	reset="\e[0m"
	#bold="\e[1m"
	bold="\e[0m" # disables bold output
	gray="\e[90m"
	echo -e "$reset$bold$@$reset$gray"
}

announce "Checking online version..."
api=$(curl "https://services.gradle.org/versions/current" --silent)
current_version=$(echo "$api" | jq .version --raw-output)
announce "Checking installed version..."
is_installed=$(command -v gradle 2> /dev/null)

install_gradle() {
	if [[ -d "$install_directory" ]]; then
		announce "Removing existing directory..."
		rm -r "$install_directory"
	fi

	announce "Getting ready..."

	mkdir "$install_directory"

	cd "$install_directory"

	download_url=$(echo "$api" | jq .downloadUrl --raw-output)

	announce "Downloading..."

	wget "$download_url" --no-verbose

	announce "Unzipping..."

	unzip -q ./gradle*.zip

	announce "Cleaning up zip..."

	rm ./gradle*.zip

	announce "Installing to $install_directory..."

	dir=$(ls)

	mv $dir/* .

	announce "Cleaning up..."

	rmdir "$dir"

	announce "Adding symlink to $HOME/.local/bin..."

	if [[ ! -d "$bin_dir" ]]; then
		mkdir "$HOME/.local/bin/"
	fi

	symlink="$bin_dir/gradle"

	 if [[ -e "$symlink" ]]; then
		 rm "$symlink"
	 fi

	ln -s "$install_directory/bin/gradle" "$symlink"

	echo -e "\e[0mAll done! Don't forget to add ~/.local/bin to \$PATH, if it isn't yet."

	exit

}

if [[ -z $is_installed ]]; then
	announce "No version of Gradle detected! Install now? (y/n):"
	read -n 1 answer
	echo
	if [[ $answer == "y" ]]; then
		install_gradle
	else
		exit
	fi
fi

installed_version=$(gradle --version | grep "Gradle" | grep --only-matching "[0-9]\.[0-9]" 2> /dev/null)
if [[ $current_version > $installed_version ]]; then
	announce "Currently installed version is out of date ($installed_version vs $current_version). Update? (y/n)"
	read -n 1 answer
	echo
	if [[ $answer == "y" ]]; then
		install_gradle
	else
		exit
	fi
fi

announce "Gradle is up to date! ($installed_version == $current_version)"

