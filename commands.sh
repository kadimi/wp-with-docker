#!/bin/sh

WWD_HOME="$HOME/sites"
wwd-verify-name() {
	site=${1:?Missing name}
	if [[ ! $site =~ ^[a-z0-9][a-z0-9-]*$ ]]; then
		return 1
	fi
}
wwd-verify-exists() {
	wwd-verify-name $1
	if [ ! $? -eq 0 ];then
		return 1
	fi
	if [ ! -d "$WWD_HOME/$1" ]; then
		return 1
	fi
}
wwd-start() {
	seconds=2
	wwd-verify-exists $1
	if [ ! $? -eq 0 ];then
		echo "Container \"$1-db\" doesn't exist."
		return 1
	fi
	composer run -q -d $WWD_HOME/$1 db:start > /dev/null 2>&1
	if [ $? -eq 0 ];then
		echo "Container \"$1-db\" started."
	else
		echo "Container \"$1-db\" couldn't start."
		return 1
	fi
	echo "Waiting ${seconds}s before visiting https://$1.test."
	sleep $seconds
	composer run -q -d $WWD_HOME/$1 site:visit
}
wwd-stop() {
	wwd-verify-exists $1
	if [ ! $? -eq 0 ];then
		echo "Container \"$1-db\" doesn't exist."
		return 1
	fi
	composer run -q -d $WWD_HOME/$1 db:stop > /dev/null 2>&1 
	if [ $? -eq 0 ];then
		echo "Container \"$1-db\" stopped."
	else
		echo "Container \"$1-db\" couldn't stop."
		return 1
	fi
}
wwd-create() {
	wwd-verify-name $1
	if [ ! $? -eq 0 ];then
		echo "Invalid site name \"$1\"."
		return 1
	fi
	wwd-verify-exists $1
	if [ $? -eq 0 ];then
		echo "Site \"$1\" already exists."
		return 1
	fi
	mkdir -p "$WWD_HOME"
	git clone git@github.com:kadimi/wp-with-docker.git "$WWD_HOME/$1"
	composer install -d $WWD_HOME/$1
	composer run -d $WWD_HOME/$1 setup
	composer run -d $WWD_HOME/$1 site:visit
}
wwd-delete() {
	wwd-verify-exists $1
	if [ ! $? -eq 0 ];then
		echo "Site \"$1\" doesn't exist."
		return 1
	fi
	composer run -q -d $WWD_HOME/$1 db:stop > /dev/null 2>&1 
	if [ $? -eq 0 ];then
		echo "Container \"$1-db\" stopped."
	else
		echo "Container \"$1-db\" couldn't be stopped."
		# return 1
	fi
	sudo rm -fr "$WWD_HOME/$1"
	echo "Site \"$1\" deleted."
}
wwd-list() {
	mkdir -p "$WWD_HOME"
	du -h --max-depth=1 -L "$WWD_HOME" | sort -h | grep -v "$WWD_HOME"$
}
wwd-cmd() {
	wwd-verify-exists $1
	if [ ! $? -eq 0 ];then
		echo "Site \"$1\" doesn't exist."
		return 1
	fi
	cmd=${2:?Missing command}
	$cmd $WWD_HOME/$1
}
