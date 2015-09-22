# localdevsetup
Bash script to setup a local development environment to work on a Drupal website using docker containers on Ubuntu Linux.

Place the script setup-new-localdev.sh in the folder where you want to make subfolders for projects and run. You can clone the project with:

	git clone https://github.com/meosch/localdevsetup.git

You can specify the name of the new environment on the command line or you will be asked for one. You will be asked to enter a sudo password to properly setup permissions and ownership of files and folders. Your user should be apart of the docker group.

    setup-new-localdev.sh
or
    setup-new-localdev.sh  nameof new project

I am using this with parts of [Drude (**Dru**pal **D**ocker **E**nvironment)](https://github.com/blinkreaction/drude Drude GitHub Project) which is a Docker and Docker Compose based environment for Drupal. 

The Drude is more aimed at Windows and Mac OSes as that is what Blink Reaction is using. On these two operating systems Docker must be run inside a Linux virtual machine. This adds overhead. If I understand things correctly because Blink Reaction does not have people working on Linux, Drude is not highly tested on Linux.  I wanted something that work "just work" on Ubuntu Linux. I do heavily use the Drude **dsh** command which you should install.

## Install dsh (Drude Shell Helper)


### Mac, Windows (Babun shell), Linux

To install [dsh](#dsh) run:

    sudo curl -L https://raw.githubusercontent.com/blinkreaction/drude/master/bin/dsh -o /usr/local/bin/dsh
    sudo chmod +x /usr/local/bin/dsh


