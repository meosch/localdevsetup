#!/bin/bash
# This is a script to setup a local docker container development environment. It will be well commented so that others can take this script and change it to meet their needs. - Frederick Henderson
PS4=':${LINENO} + '
#set -x
# What is our webroot folder called?  docroot? httpdocs? public_html?
webroot="project/docroot"
# FIXME Add command line option to specify the name of the webroot folder
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
echo -e "${yellow}>>>${NC} This script, will setup a new local development environment folder in the current folder."
echo -e "${yellow}>>>${NC} The name of the development environment can be specified on the command line."
echo -e "${yellow}>>>${NC} To see help use the ${red}-h${NC} switch."
if [ ! -z ${environmentname} ]; then
  echo -e "${yellow}>>>${NC} The environment name is currently set to ${yellow}${environmentname}${NC}"
else
  echo -e "${yellow}>>>${NC} The environment name is ${yellow}not${NC} set."
fi
echo -e "${yellow}>>>${NC} The webroot folder name is set to ${yellow}${webroot}${NC}."
echo -e "${yellow}>>>${NC} This script will copy and make file and folders into the new environment folder and set appropriate permissions on them."
echo -e "${yellow}>>>${NC} It will also configure a ${green}docker-compose.yml${NC} fill with the environment name."
echo -e "${yellow}>>>${NC} This is a helper script to be used when setting up a new local development environment."
echo -e "${yellow}>>>${NC} It is only need to run this script once for the initial setup."
#echo "If links are found instead of the files and folders to move, the script will assume you have run it before and not repeat the process."
echo " "
}
# Ask the user for the name for the development environment if this was not given on the command line. This will be used for the name of the folder, container names and in the docker-compose.yml for docker-gen and also for the VirtualHost name.
askforenvironmentname(){
  if [ -z ${environmentname} ]; then
    echo -ne "${yellow}>>>${NC} ${yellow}Enter the name of the new local development environment to create: ${red}>>> ${NC}"
    read environmentname    
  fi
}
doesenvironmentexist(){
  if [ ! -z ${environmentname} ]; then
    if [ -d $environmentname ]; then
     echo -e "${yellow}>>>${NC} ${red}A folder with the environment name already exists. Now exiting!${NC}"
      exit
    fi
  fi
}
switchdirctoryifgiven(){
  if [ -z $environmentname ] ; then
  directoryrunfrom=$(cd -P -- "$(dirname -- "$0")" && pwd -P)
    environmentname=$directoryrunfrom
    cd $environmentname
  fi
}
createyesno(){
  echo -e "${yellow}>>>${NC} If this is not what you want you can now abort this script.${NC}"
  echo -e -n "${yellow}>>>${NC} Should I create a new local development environment named, ${yellow}${environmentname}${NC}? [${red}y${NC}/${green}N${NC}] "
  read -r response
response=${response,,}    # tolower
  if [[ $response !=  "y" && $response != "Y"  && $response != "yes" && $response != "Yes" ]]; then
     echo -e "${red}User aborted script! Now exiting!${NC}"
    exit
  fi
  echo ""
}
# function to run commands as super user. This will keep give the user
# option to re-enter the password till they get it right or allow them
# to exit if something goes wrong instead of continuing on. 
# Usage:
#  run_sudo_command [COMMANDS...] -FJH 2010.03.17
run_sudo_command() {
# grab the commands passed to the function and put them in a variable for safe keeping
echo -en "${red}"
sudocommand=$*
sudo $sudocommand
# Check the exit status if it is not 0 (good) then assume that the password was not entered correctly and loop them till they get it right or cancel the running of this script.
echo -en "${NC}"
while [ ! $? = 0 ]; do
echo -e -n "${yellow}>>>${NC} Something is not right here. (Did you correctly enter your password? Is the Caps-Locks on?) Do you want to try to enter the password again${green}(Yes)${NC} or exit this script${red}(No)${NC}?"
  read -r response
response=${response,,}    # tolower
  if [[ $response !=  "y" && $response != "Y"  && $response != "yes" && $response != "Yes" ]]; then
    echo -e "${yellow}>>>${NC} ${red}Exiting! User aborted the script!${NC}"
		exit
		else
		echo -en ${red}
		sudo $sudocommand
		echo -en "${NC}"
	fi
	echo -en "${NC}"
done
}
# Download docker-compose.yml, .drude folder, etc.
downloadfiles(){
# Download docker-compose files.
  mkdir ${environmentname}
    git clone https://github.com/meosch/docker-compose-localdevmeos.git ${environmentname}
    result=$?
    if [ $result -ne 0 ]; then
      echo -e "${yellow}>>>${NC} ${red}Something went wrong with the git cloning process."
      echo -e "${yellow}>>>${NC} ${red}Now exiting!${NC}"
      exiting
    fi
  rm -rf ${environmentname}/.git
# Download website helper scripts
  git clone git@github.com:meosch/websitescripts.git ${environmentname}/scripts
  result=$?
    if [ $result -ne 0 ]; then
      echo -e "${yellow}>>>${NC} ${red}Something went wrong with the git cloning process."
      echo -e "${yellow}>>>${NC} ${red}Now exiting!${NC}"
      exiting
    fi
}  
# Create needed folders and then set owner and group, plus appropriate permissions.
createandpermissionfolders(){
  mkdir -p ${environmentname}/${webroot}
  mkdir ${environmentname}/mysqldata
  mkdir ${environmentname}/private
  mkdir -p ${environmentname}/.home-localdev/.drush
  # Move and rename local development environment drush aliases template file for the new environment.
#  mv ${environmentname}/localdevmeos.aliases.drushrc.php ${environmentname}/.home-localdev/.drush/${environmentname}.aliases.drushrc.php
  # Move and rename the drush aliases file template for the new environment for the docker host, but not if it already exists.
  mv -n ${environmentname}/host.aliases.drushrc.php ~/.drush/${environmentname}.aliases.drushrc.php
  # Move and rename local docker @parent development environment drush aliases template file for the new environment, but not if it already exists.
  mv -n ${environmentname}/local.docker.aliases.drushrc.php ${environmentname}/.home-localdev/.drush/docker.aliases.drushrc.php
  # Move and rename host docker @parent development environment drush aliases template file for the new environment, but not if it already exists.
  mv -n ${environmentname}/host.docker.aliases.drushrc.php $HOME/.drush/docker.aliases.drushrc.php
  # Rename the drush aliases file template for use with other Docker containers.
  mv -n ${environmentname}/docker_add_on_localdevmeos.aliases.drushrc.php ${environmentname}/${environmentname}-docker_add_on.aliases.drushrc.php
  # Move our bash environment configuration files in to our artificial $HOME directory.
  for movethis in ".bash_aliases" ".bashrc" ".drush.bashrc" ".profile"
    do
      if [ -f ${environmentname}/$movethis ]; then
        mv ${environmentname}/${movethis} ${environmentname}/.home-localdev/
      fi
    done
  mkdir -p ${environmentname}/.home-localdev/bin
  mv ${environmentname}/.git-prompt.sh ${environmentname}/.home-localdev/bin/
  if [ -f ./authorized_keys ]; then
    mkdir -p ${environmentname}/.home-localdev/.ssh
    cp ./authorized_keys ${environmentname}/.home-localdev/.ssh/
  else
    echo -e "${yellow}A file called ${red}authorized_keys${yellow} was not found in this folder.${NC}"
    echo -e "For passwordless login to this container using a drush alias, such as, ${yellow}@docker.localdev${NC}"
    echo -e "you will need to copy your public key to ${yellow}${environmentname}/.home-localdev/.ssh/authorized_keys${NC}."
  fi
  echo -e ""
  echo -e "${yellow}>>>${NC} Next I will set as needed the owner, group and permissions on files and folders."
  echo -e "${yellow}>>>${NC} You will be asked for your sudo password unless you have recently used it."
  echo ""
# Set the current user as owner and docker as group for our environment folder.
  run_sudo_command chown -R ${USER}:www-data ${environmentname}
# Set the group sticky bit so that any new files or folders belong to the group www-data set above.  
  run_sudo_command chmod g+s -R ${environmentname}
# Give the www-data group write permissions for the webroot.
  run_sudo_command chmod -R g+w ${environmentname}/${webroot}
# Set the group sticky bit so that any new files or folders in the webroot belong to the group www-data set above.
  run_sudo_command chmod g+s -R ${environmentname}/${webroot}
# Give the www-data group write permissions for the private files folder.
  run_sudo_command chmod -R g+w ${environmentname}/private
# Set the group sticky bit so that any new files or folders in the private files folder belong to the group www-data set above.
  run_sudo_command chmod g+s -R ${environmentname}/private

}
# Configure the  docker-compose.yml with the development environment name by replacing the phrase localdevmeos in a number of places.
replacelocaldevmeos(){
  sed -i s/localdevmeos/${environmentname}/ ${environmentname}/docker-compose_all_containers.yml
  sed -i s/localdevmeos/${environmentname}/ ${environmentname}/docker-compose_add_on_site.yml
#  sed -i s/localdevmeos/${environmentname}/  ${environmentname}/.home-localdev/.drush/${environmentname}.aliases.drushrc.php
  sed -i s/localdevmeos/${environmentname}/ ~/.drush/${environmentname}.aliases.drushrc.php
  sed -i s/localdevmeos/${environmentname}/  ${environmentname}/${environmentname}-docker_add_on.aliases.drushrc.php
  sed -i s/localdevmeos/${environmentname}/  ${environmentname}/docker-gen.conf
  
}
finished(){
  echo ""
  echo -e "${yellow}>>>${NC} All done setting up the new local development environment ${yellow}$environmentname${NC}."
  echo -e "${yellow}>>>${NC} ${green}Have fun ${yellow}storming${green} the ${red}castle!${NC}"
  echo -e "To start your new environment run: ${yellow}cd ${environmentname}${NC} then ${yellow}dsh up${NC}."
  echo -e "${red}NOTE:${yellow}It can take around ~40 seconds before DNS knows about your containers and you can access it without ${yellow}dsh${NC}."
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
doesenvironmentexist
switchdirctoryifgiven
setitup
else
informuser
askforenvironmentname
doesenvironmentexist
switchdirctoryifgiven
createyesno
setitup
fi
