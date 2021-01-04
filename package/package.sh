#!/usr/bin/env bash
##
## Copyright (c) 2020 Hanson Robotics.
##
## This file is part of Hanson AI.
## See https://www.hansonrobotics.com/hanson-ai for further info.
##
## Licensed under the Apache License, Version 2.0 (the "License");
## you may not use this file except in compliance with the License.
## You may obtain a copy of the License at
##
##     http://www.apache.org/licenses/LICENSE-2.0
##
## Unless required by applicable law or agreed to in writing, software
## distributed under the License is distributed on an "AS IS" BASIS,
## WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
## See the License for the specific language governing permissions and
## limitations under the License.
##

package() {
    local reponame=pololu-motors

    mkdir -p $BASEDIR/src
    rsync -r --delete \
        --exclude ".git" \
        --exclude "package" \
        $BASEDIR/../ $BASEDIR/src/$reponame

    get_version $1

    # remove pyserial
    sed -i 's/pyserial//g' $BASEDIR/src/$reponame/setup.py

    local name=head-python-pololu-motors
    local desc="Pololu Motor Control API"
    local url="https://api.github.com/repos/hansonrobotics/$reponame/releases"

	ROS_PYTHON_VERSION=${ROS_PYTHON_VERSION:-3}
	if [[ $ROS_PYTHON_VERSION == 3 ]]; then
		PYTHON_BIN=python3
		PYTHON_PKG_PREFIX=$HR_PREFIX/py3env/lib/python3.8/dist-packages
	else
		PYTHON_BIN=python
		PYTHON_PKG_PREFIX=$HR_PREFIX/py2env/lib/python2.7/dist-packages
	fi

    fpm -s python -t deb -n "${name}" -v "${version#v}" --vendor "${VENDOR}" \
        --url "${url}" --description "${desc}" ${ms} --force \
        --deb-no-default-config-files \
        -p $BASEDIR/${name}_VERSION_ARCH.deb \
        -d "python-serial" \
        --python-bin $PYTHON_BIN \
        --python-install-bin $HR_PREFIX/bin \
        --python-install-lib $PYTHON_PKG_PREFIX \
        $BASEDIR/src/$reponame/setup.py

    rm -r $BASEDIR/src
}

if [[ $(readlink -f ${BASH_SOURCE[0]}) == $(readlink -f $0) ]]; then
    BASEDIR=$(dirname $(readlink -f ${BASH_SOURCE[0]}))
    source $BASEDIR/common.sh
    set -e

    package $1
fi
