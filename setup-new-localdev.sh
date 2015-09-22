#!/bin/bash
# This is a script to setup a local docker container development environment. It will be well commented so that others can take this script and change it to meet their needs. - Frederick Henderson
PS4=':${LINENO} + '
#set -x
# What is our webroot folder called?  docroot? httpdocs? public_html?
webroot="public_html"
# END CONFIGURATION #############################
# set yes to no ;)
yes=0
runningscriptname=$(basename "$0")
function usage()
{
 echo "Usage ${0##*/}  -y -h <environment name>"
 echo "Where:"
 echo "-y answers yes to questions. For use in scripts."
 echo "-h displays this help info."
 echo "<environment name> used for the folder name and the virtual host name."
 echo ""
}

while getopts yh option
do
  case "${option}" in
    h)
      usage
      exit 2
    ;;
    y)
      yes=1
    ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
    ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
    ;;
  esac
done
# get rid of our flag options and arguments
shift $((OPTIND-1))

# Save environment name if given on command lines
environmentname=$1

# Console colors
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[1;33m'
NC='\033[0m'

#red='\e[1;31m'
#NC='\e[0m' # No Color
pwd=$(pwd)

################### FUNCTIONS ##########################
pause(){
   read -p "$*"
}
informuser(){
echo -e "This script, will setup a new local development environment folder in the current folder."
echo "The name of the development environment can be specified on the command line."
echo -e "To see help use the ${red}-h${NC} switch."
if [ -n ${environmentname} ]; then
  echo -e "The environment name is currently set to ${green}${environmentname}${NC}"
else
  echo -e "The environment name is ${yellow}not${NC} set."
fi
echo -e "This script will copy and make file and folders into the new environment folder and set appropriate permissions on them. It will also configure a docker-compose.yml fill with the environment name."
echo "This is a helper script to be used when setting up a new local development environment."
echo "It is only need to run this script once for the initial setup."
#echo "If links are found instead of the files and folders to move, the script will assume you have run it before and not repeat the process."
echo " "
}
# Ask the user for the name for the development environment if this was not given on the command line. This will be used for the name of the folder, container names and in the docker-compose.yml for docker-gen and also for the VirtualHost name.
askforenvironmentname(){
  if [ -z ${environmentname} ]; then
    echo -ne "Enter the name of the new local development environment to create."
    read environment
  fi
}
switchdirctoryifgiven(){
  if [ ! -z $environmentname ] ; then
    cd $environmentname
  else
  directoryrunfrom=$(cd -P -- "$(dirname -- "$0")" && pwd -P)
    environmentname=$directoryrunfrom
    cd $environmentname
  fi
}
notwhatyouwanted(){
echo -e "If this is not what you want hit ${red}Ctrl + C${NC} to abort this script or press the ${red}Enter${NC} key to continue."
pause
echo " "
}
createyesno(){
  echo -e -n "Should I create a new local development environment named, ${green}${environmentname}${NC}? ${red}[y/N]${NC} "
  read -r response
response=${response,,}    # tolower
  if [[ $response !=  "y" && $response != "Y"  && $response != "yes" && $response != "Yes" ]]; then
     echo -e "${red}User aborted script! Now exiting!${NC}"
    exit
  fi
}
# function to run commands as super user. This will keep give the user
# option to re-enter the password till they get it right or allow them
# to exit if something goes wrong instead of continuing on. 
# Usage:
#  run_sudo_command [COMMANDS...] -FJH 2010.03.17
run_sudo_command() {
# grab the commands passed to the function and put theme in a variable for safe keeping
sudocommand=$*
sudo $sudocommand
# Check the exit status if it is not 0 (good) then assume that the password was not entered correctly and loop them till they get it right or cancel the running of this script.
while [ ! $? = 0 ]; do
zenity --question --title='Local Development Environment Setup - Attention Needed!' --text="Something is not right here. (Did you correctly enter your password? Is the Caps-Locks on?) Do you want to try to enter the password again(Yes) or exit this script(No)?"
	if [ ! $? = 0 ]; then
		exit
		else 
		sudo $sudocommand
	fi
done
}
# Download docker-compose.yml, .drude folder, etc.
downloadfiles(){
  mkdir ${environmentname}
    git clone https://github.com/meosch/docker-compose-localdevmeos.git ${environmentname}
  rm -rf ${environmentname}/.git
}  
# Create needed folders, public_html and then set owner and group, plus appropriate permissions.
createandpermissionfolders(){
  mkdir ${environmentname}/${webroot}
  run_sudo_command chown -R www-data:docker ${environmentname}/${webroot}
  run_sudo_command chmod -R g+w ${environmentname}/${webroot}
  run_sudo_command chown -R www-data:docker ${environmentname}/.drude
}
# Configure the  docker-compose.yml with the development environment name by replacing the phrase localdevmeos in 2 places.
replacelocaldevmeos(){
  sed -i s/localdevmeos/${environmentname}/ ${environmentname}/docker-compose.yml
}
finished(){
  echo "All settting up the new local development environment. Have fun storming the castle!"
}
setitup(){
  downloadfiles
  createandpermissionfolders
  replacelocaldevmeos
  finished
}

### MAIN PROGRAMM ###
if [ $yes = 1 ]; then
askforenvironmentname
switchdirctoryifgiven
setitup
else
askforenvironmentname
switchdirctoryifgiven
informuser
notwhatyouwanted
createyesno
setitup
fi
