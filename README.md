# Updater
This is my personal update script, designed for Ubuntu 20.04 and 22.04.

It updates:
* [`tldr`](https://tldr.sh/) cache using [`./tldr_update.sh`](./tldr_update.sh) (to account for variantions in the implementation of `tldr`), or, if that doesn't exist, `tldr --update_cache`
* `snap` packages using `sudo snap refresh`
* `apt` packages using `sudo apt update && sudo apt upgrade` (no `-y`)
* [`Gradle`](https://gradle.org/) using [`./gradle_update.sh`](./gradle_update.sh)
  * This installs to `$GRADLE_HOME/install` (by default `$HOME/.gradle/install`) and adds a symlink to `$HOME/.local/bin`
  * This does *not* add `$HOME/.local/bin` to path

## License
Updater is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

Updater is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with Updater, in [`./LICENSE`](./LICENSE). If not, see [<https://www.gnu.org/licenses/>](https://www.gnu.org/licenses/).
