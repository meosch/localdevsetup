# localdevsetup
Bash script to setup a local development environment to work on a Drupal website using docker containers on Ubuntu Linux.

## Setup dnsmasq on Ubuntu
See the documentation file, [dnsmasq_with_network-manager_for_docker.md](https://github.com/meosch/docker-gen/blob/master/dnsmasq-configuration/dnsmasq_with_network-manager_for_docker.md) on the [meosch/docker-gen](https://github.com/meosch/docker-gen) project for information on how to setup dnsmasq on Ubuntu to redirect all ***.docker/** addresses to the containers and to allow you to ssh from the host computer to containers and in between containers.


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

    sudo curl -L https://raw.githubusercontent.com/meosch/dsh/master/dsh -o /usr/local/bin/dsh
    sudo chmod +x /usr/local/bin/dsh


### Upgrading
Older versions of this script defaulted the webroot created to **public_html**. The current version uses **project/docroot** to be similar to the Drupal composer project defaults.