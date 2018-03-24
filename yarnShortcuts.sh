#!/bin/bash

source ./graphics.sh

#Some formatting variables
red=$(tput setaf 1)
yellow=$(tput setaf 3)
magenta=$(tput setaf 5)
cyan=$(tput setaf 6)
normal=$(tput sgr0)

#global variables
correctPath=false

#projects Selection options
appOpts=("htz-frontend")

clear

#project Selection
echo "Which project's shortcuts would yo like to add to your .bashrc file ?"

select opt in "${appOpts[@]}"
do
  case ${opt} in
    "htz-frontend")
      appName="htz-frontend"
      break
      ;;
    *) echo "${red}Invalid option${normal}";;
  esac
done

echo ' '

#OS Selection options
osOpts=("Linux/Mac" "Windows")

# OS Selection
echo "What OS are you on?"

select opt in "${osOpts[@]}"
do
  case ${opt} in
    "Linux/Mac")
      rcPath="/home/eranm6/"
      rcFileName=".bashrc"
      break
      ;;
    "Windows")
      rcPath="/etc/"
      rcFileName="bash.bashrc"
      break
      ;;
    *) echo "${red}Invalid option${normal}";;
  esac
done

echo ' '

# Get project path
while [[ ${correctPath} == false ]]
do
	exist=true
	repo=true
	
	read -p "${magenta}Please enter the absolute path to the $appName folder${normal}: " projectPath
	echo ' '

	# check if the folder exists
	if [[ -d "$projectPath" ]]; then 
	  if [[ -L "$projectPath" ]]; then
		# It is a symlink!
		echo "${red}not absolute path${normal}"
		echo "${yellow}$noDir${normal}"
		exist=false
	  fi
	else
		echo "${red}Invalid path${normal}"
		echo "${yellow}$noDir${normal}"
		exist=false
	fi

	if [[ ${exist} == true ]]; then
	    #get the repository's remote URL and check if it's belong to the selected app
		originUrl=$(git --git-dir "$projectPath/.git" config --get remote.origin.url)

		re="^.+/(.+).git$"

		if [[ ${originUrl} =~ $re ]]; then
			if ! [[ ${BASH_REMATCH[1]} == ${appName} ]]; then
				echo "${red}This is not $appName project folder${normal}"
				echo "${yellow}$notApp${normal}"
				repo=false
			fi
		else
			echo "${red}There's no git repository in that folder${normal}"
			echo "${yellow}$noGit${normal}"
			repo=false
		fi
	fi
	
	if [[ ${exist} == true && ${repo} == true ]]; then
		correctPath=true
	fi
done

#check if the function already exists in .bashrc file
grep -q "source ${rcPath}${appName}.sh" ${rcPath}${rcFileName}

if [[ $? == 0 ]]; then
	read -p "${magenta}$appName function already exists on your machine. Do you want to overwrite it?${normal} [y/N]" response
	echo ' '
    case  "$response" in
        y|Y|[yY][eE][sS])
            overwrite=true
	        writeToFile=true
            ;;
        *)
            writeToFile=false
            ;;
    esac
else
    overwrite=false
    writeToFile=true
fi

if [[ ${writeToFile} == "true" ]]; then

    #write the function file.
    if [[ ${appName} == "htz-frontend" ]]; then
        cat <<FNC >${rcPath}${appName}.sh
#!/usr/bin/env bash

function htz(){
    cd ${projectPath}

    red=\$(tput setaf 1)
    normal=\$(tput sgr0)

    if ! [[ -z "\$1" ]]; then
        if [[ \$1 == "test" || \$1 == "bootstrap" ]]; then
            yarn \$1
        elif [[ \$1 == "app" ]]; then
            if ! [[ -z "\$2" ]]; then
                if ! [[ -z "\$3" ]]; then
                    if [[ \$2 == "haaretz" ]]; then
                        yarn workspace @haaretz/haaretz.co.il \$3
                    else
                        yarn workspace @haaretz/\$2 \$3
                    fi
                else
                    echo "\${red}You need to specify a command that you'd like to execute on the app \$2\${normal}"
                fi
            else
                echo "\${red}You didn't select any app...\${normal}"
            fi
        elif ! [[ -z "\$2" ]]; then
            if [[ \$1 == "components" || \$1 == "theme" ]]; then
                yarn workspace @haaretz/htz-\$1 \$2
            else
                yarn workspace @haaretz/\$1 \$2
            fi
        else
            echo "\${red}You didn't choose an action to preform on \$1\${normal}"
        fi
    fi
}
FNC
        if [[ ${overwrite} == "false" ]]; then
            #import the function file to .bashrc file.
            echo "source ${rcPath}${appName}.sh" >> ${rcPath}${rcFileName}
        fi
    fi

    #reload the .bashrc file (DOESN'T WORK)
    $(. ${rcPath}${rcFileName})

    echo "${yellow}$success${normal}"
    echo "${cyan}Sweet zombie Jebus${normal}"

    echo "Please run ${magenta}. ${rcPath}${rcFileName}${normal} to reload your settings"
fi
exit 1
