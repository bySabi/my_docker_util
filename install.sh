#!/bin/bash
set -e
set +x

project_dir="my_docker_util"


## goto script dir
cd "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

script_dir_parent=${PWD##*/}
current_user=${SUDO_USER}

[ ${INSTALLTYPE} ] || INSTALLTYPE=develop

main() {
	isrootuser
	setup_script ${script_dir_parent}

	install_packages
	install_docker
	set_bash_completion
	set_docker_env
	create_joquer_user
	set_dnsmasq
	## *** DON'T on production
	[ ${INSTALLTYPE} == 'develop' ] && {
		#set_docker_limit
		set_network_interface
		install_pipework
		add_user_to_docker_group
		set_inotify_max
	}
}

set_network_interface() {
	echo ">> Install custom network interface-bridge"
		install -o root -m 644 conf/interfaces-bridge /etc/network/interfaces
		echo -e "Default IP: \e[00;5m192.168.0.199\e[00m ... change before restart"
	exit_func $?
}

install_packages() {
	echo ">> Install packages"
		source conf/package-needed
	exit_func $?
}

install_docker() {
	echo ">> Install docker"
		source conf/install-docker
	exit_func $?
}

set_bash_completion() {
	echo ">> Set bash completion"
		source conf/docker-bash-completion-install
	exit_func $?
}

set_docker_env() {
	echo ">> Set docker environment"
		source conf/set-docker-env
	exit_func $?
}

set_docker_limit() {
	echo ">> Set docker limit"
		source conf/set-docker-limit
	exit_func $?
}

create_joquer_user() {
	echo ">> Create \"joquer\" user"
		useradd -M -U -G docker -s /bin/false -u 7777 joquer
	exit_func $?
}

set_dnsmasq() {
	echo ">> Setup dnsmasq"
		source conf/setup-dnsmasq
	exit_func $?
}

install_pipework() {
	echo ">> Install pipework"
		source conf/install-pipework
	exit_func $?
}

add_user_to_docker_group() {
	echo ">> Add user: ${current_user} to docker group"
		source conf/add-user-group-docker
	exit_func $?
}

set_inotify_max() {
	echo ">> Set inotiy sysctl max"
		source conf/set-inotify-max
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
		chmod +x install.sh && ./install.sh
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
