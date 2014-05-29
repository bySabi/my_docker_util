#!/bin/bash

docker_directory=~/develop/docker
cd ${docker_directory}

git pull origin master
# make binary
sudo make binary

docker_dir=${docker_directory}/bundles
if [ -d ${docker_dir} ]
then
	docker_ver=$(ls -lrt ${docker_dir} | awk '{ f=$NF }; END{ print f }')
	docker_file=${docker_dir}/${docker_ver}/binary/docker-${docker_ver}
	if [ -f ${docker_file} ]
	then
		sudo service docker stop
		sudo cp $(which docker) $(which docker)_
		sudo install -o root -m 755 ${docker_file} $(which docker)
		echo "install file: ${docker_file}"
		sudo service docker start
	else
		echo "no exist: ${docker_file}"
		exit 1
	fi
else
	echo "no exist: ${docker_dir}"
	exit 1
fi

#cd ${docker_directory}
#sudo make test

