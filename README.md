# Updater

This is my personal update script, designed for Ubuntu 24.04.

It updates:

- [`tldr`](https://tldr.sh/) cache using [`./tldr_update.sh`](./tldr_update.sh)
  (to account for variations in the implementation of `tldr`),
  or, if that doesn't exist, `tldr -u`.
- `snap` packages using `sudo snap refresh`.
- `apt` packages using `sudo apt update && sudo apt upgrade` (no `-y`).
- [`Gradle`](https://gradle.org/) using [`./gradle_update.sh`](./gradle_update.sh).
  - This installs to `$GRADLE_HOME/install`
    (by default `$HOME/.gradle/install`)
    and adds a symlink to `$HOME/.local/bin`.
    - This does *not* add `$HOME/.local/bin` to `$PATH`
  - This checks for a `gradle_lock` file in the script's directory.
    If `gradle_lock` exists, this will ignore the Gradle API and refer to it for the latest version.
    - `gradle_lock` should contain nothing but the version
      as it appears in the "version" field of [the Gradle API's version list](https://services.gradle.org/versions/all).
- [`act`](https://github.com/nektos/act).
- Checks for Docker updates, but does not install them.

Additionally, though there is no update logic yet,
there is also [`perf/`](./perf/),
which provides a Docker container based on [`buty4649/wsl-perf`](https://github.com/buty4649/wsl-perf)
for building `perf` for WSL (Microsoft Kernel 5.15).

## License

Updater is free software: you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by the Free Software Foundation,
either version 3 of the License, or (at your option) any later version.

Updater is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with Updater (located within [LICENSE](./LICENSE)).
If not, see <https://www.gnu.org/licenses/>.
