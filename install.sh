#!/bin/bash
set -e
set +x

project_dir="my_docker_util"


## goto script dir
cd "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

script_dir_parent=${PWD##*/}


main() {
	isrootuser
	setup_script ${script_dir_parent}

	install_packages
	install_docker
	set_docker_env
	set_dnsmasq
	install_pipework
}


install_packages() {
	echo ">> Install packages"
		source conf/package-needed 1>/dev/null
	exit_func $?
}

install_docker() {
	echo ">> Install docker"
		source conf/docker-install 1>/dev/null
	exit_func $?
}

set_docker_env() {
	echo ">> Set docker environment"
		source conf/set-docker-env
	exit_func $?
}

set_dnsmasq() {
	echo ">> Set dnsmasq"
		source conf/setup-dnsmasq
	exit_func $?
}

install_pipework() {
	echo ">> Install pipework"
		source conf/install-pipework
	exit_func $?
}

isrootuser() {
	[ $(id -u) = 0 ] || {
		echo "This script must be run as root" 1>&2
		exit 1
	}
}

setup_script() {
	if [ "$1" != ${project_dir} ]; then
		if ! which git > /dev/null
		then
			echo ">> Install git"
				apt-get install -y --no-install-recommends git 1>/dev/null
			exit_func $?
		fi
		echo ">> clone \"${project_dir}\" repo"
			[ -d ${project_dir} ] && rm -fr ${project_dir}
			git clone https://github.com/bySabi/${project_dir}.git
		exit_func $?
		cd ${project_dir}
		git-crypt init ~/.git-crypt/git-crypt.key
		chmod +x install.sh && ./install.sh &
		exit 0
	fi
}

exit_func() {
	local exitcode=${1}
	if [ $exitcode == 0 ]; then 
		echo -e "\e[00;32mOK\e[00m"
	else 
		echo -e "\e[00;31mFAIL\e[00m"
	fi
}


main "$@"
exit 0
