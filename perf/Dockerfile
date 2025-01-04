# SPDX-License-Identifier: GPL-3.0-or-later
#
# Copyright © 2024 buty4649 <buty4649@gmail.com>
# Copyright © 2025 RemasteredArch
#
# Modified from <https://github.com/buty4649/wsl-perf> @ ee0ce77894049349a6e43f649cacef5cd9c2686d
#
# Originally licensed under the MIT license:
# <https://github.com/buty4649/wsl-perf/blob/ee0ce77894049349a6e43f649cacef5cd9c2686d/LICENSE>,
# relicensed GPL-3.0-or-later.
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

FROM ubuntu:24.04 AS build

ARG WSL_VERSION=5.15

RUN apt-get update && apt-get upgrade && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    'binutils-dev' \
    'binutils-dev' \
    'binutils-dev' \
    'bison' \
    'build-essential' \
    'debuginfod' \
    'dpkg-dev' \
    'fakeroot' \
    'flex' \
    'libaio-dev' \
    'libbabeltrace-dev' \
    'libcap-dev' \
    'libdw-dev' \
    'libdw-dev' \
    'libdwarf-dev' \
    'libdwarf-dev' \
    'libelf-dev' \
    'libelf-dev' \
    'libiberty-dev' \
    'liblzma-dev' \
    'libncurses5-dev' \
    'libnewt-dev' \
    'libnuma-dev' \
    'libperl-dev' \
    'libpfm4-dev' \
    'libslang2-dev' \
    'libssl-dev' \
    'libssl-dev' \
    'libtraceevent-dev' \
    'libunwind-dev' \
    'libzstd-dev' \
    'libzstd1' \
    'python3' \
    'python3' \
    'python3-dev' \
    'python3-setuptools' \
    'systemtap-sdt-dev' \
    'tar' \
    'wget' \
    'zlib1g-dev'

WORKDIR /usr/src
RUN <<COMMAND
    wget "https://github.com/microsoft/WSL2-Linux-Kernel/archive/refs/heads/linux-msft-wsl-${WSL_VERSION}.y.tar.gz" -O 'linux-msft-wsl.tar.gz'
    mkdir 'linux'
    tar -C 'linux' -xf 'linux-msft-wsl.tar.gz' --strip-components=1
    cd 'linux/tools/perf'
    make LDFLAGS='-static' WERROR=0
COMMAND

WORKDIR /usr/src/perf
RUN <<COMMAND
    mkdir -p usr/bin DEBIAN
    cp -p /usr/src/linux/tools/perf/perf usr/bin/
COMMAND

COPY DEBIAN/control DEBIAN/

WORKDIR /usr/src
RUN fakeroot dpkg-deb --build /usr/src/perf

FROM scratch
COPY --from=build /usr/src/perf.deb /
ENTRYPOINT ["/perf.deb"]
