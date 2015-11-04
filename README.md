# localdevsetup
Bash script to setup a local development environment to work on a Drupal website using docker containers on Ubuntu Linux.

## Setup dnsmasq on Ubuntu to redirect all *.docker/ addresses to the containers
Create the file /etc/dnsmasq.d/docker with the following line:

	address=/.docker/172.17.42.1
	
172.17.42.1 seems to be the default ip address that the **docker0** network interface will attach to, if it is not in use. If the Docker daemon is running you can check the ip address of the **docker0** interface by running:

	ip addr show dev docker0 | awk -F'[ /]*' '/inet /{print $3}'  
[\(from **Using dnsmasq to link Docker containers** \)](https://blog.amartynov.ru/archives/dnsmasq-docker-service-discovery/ "Using dnsmasq to link Docker containers")

Then restart dnsmasq with:
	sudo service dnsmasq restart
	
If you find that after a reboot that dnsmasq is not running it maybe due to an issue with the default NetworkManager dnsmasq configuration file. You will notice that you cannot reach your development environment in the browser. Run the following to check if dnsmasq is running.

	ps -A |grep dnsmasq

If dnsmasq fails to start at boot check configuration files in /etc/dnsmasq/  and make sure that there are not any "**bind-interfaces**" these should be "**bind-dynamic**".  More info: https://bugs.launchpad.net/ubuntu/+source/dnsmasq/+bug/1027808/comments/6

I found that I had to change the line in /etc/dnsmasq.d/network-manager:

	bind-interfaces
to
	bind-dynamic
however, this file states, "WARNING: changes to this file will get lost if network-manager is removed." YMMV

## Installation
Place the script setup-new-localdev.sh in the folder where you want to make subfolders for projects and run. You can clone the project with:

	git clone https://github.com/meosch/localdevsetup.git

You can specify the name of the new environment on the command line or you will be asked for one. You will be asked to enter a sudo password to properly setup permissions and ownership of files and folders. Your user should be apart of the docker group.

    setup-new-localdev.sh
or
    setup-new-localdev.sh  nameof new project
    
Setting up a new environment becomes as easy as running the following commands
    
    ./setup-new-localdev.sh -y hamburger
    cd hamburger/
    drush dl drupal -y --drupal-project-rename=public_html
    dsh up
Then in your browser go to [hamburger.docker/](http://hamburger.docker/ "hamburger local development environment") If typing this in manually make sure to include the trailing slash (**/**) as without it or a preceeding **http://** the browser will do a search for hamburger.dock instead of a dns lookup. 

I am using this with parts of [Drude (**Dru**pal **D**ocker **E**nvironment)](https://github.com/blinkreaction/drude "Drude GitHub Project") which is a Docker and Docker Compose based environment for Drupal. 

The Drude is more aimed at Windows and Mac OSes as that is what Blink Reaction is using. On these two operating systems Docker must be run inside a Linux virtual machine. This adds overhead. If I understand things correctly because Blink Reaction does not have people working on Linux, Drude is not highly tested on Linux.  I wanted something that "just works" on Ubuntu Linux. I do heavily use the Drude **dsh** command which you should install.

## Install dsh (Drude Shell Helper)


### Mac, Windows (Babun shell), Linux

To install [dsh](#dsh) run:

    sudo curl -L https://raw.githubusercontent.com/blinkreaction/drude/master/bin/dsh -o /usr/local/bin/dsh
    sudo chmod +x /usr/local/bin/dsh


