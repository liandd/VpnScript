#!/bin/bash
#autor: Unkn0wn1122
#helper: liandd
#Colours
greenColour="\e[0;32m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m"
blueColour="\e[0;34m"
yellowColour="\e[0;33m"
purpleColour="\e[0;35m"
turquoiseColour="\e[0;36m"
grayColour="\e[0;37m"

function ctrl_c() {
	echo -e "\n\n ${redColour} [!] Bye... ${endColour}\n"
	tput cnorm && exit 1
}

# Ctrl + c
trap ctrl_c INT

function helpPanel() {
	echo -e "\n\n${grayColour}Usage:${endColour} ${yellowColour}./vpnConnection.sh < -c >, < -d >, < -h >${endColour}

    ${purpleColour}-c${endColour} ${yellowColour}[*]${endColour} ${grayColour}Start Connection with the vpn${endColour}

    ${purpleColour}-d${endColour} ${yellowColour}[*]${endColour} ${grayColour}Close connection${endColour}

    ${purpleColour}-h${endColour} ${yellowColour}[*]${endColour} ${grayColour}this help panel${endColour}\n\n"
}

function Connect() {
	ovpnFile=$(find / -type f -name 'lab_*.ovpn' 2>/dev/null &)
	psId1=$!
	wait $psId1
  command -v openvpn >/dev/null 2>&1 || {
    echo -e "\n${redColour}[!] I requiere "openvpn" package...\n${endColour}";
    echo -e "${yellowColour}[*]${endColour} ${grayColour}do you want to install this package -> ${endColour}${grayColour}"${endColour}${redColour}openvpn${endColour}${grayColour}"${endColour}"
    read -r -p "Are you sure? [y/N] :" response
    response=${response,,}
    if [[ "$response" =~ ^(yes|y)$ ]]; then
      if [[ -x "$(command -v apt)" ]]; then
        echo "installing..."
        installed=$(sudo apt install openvpn -y)
        psId2=$!
        wait $psId2
        echo -e "\n${purpleColour}[*] Succesfully installed in debian based!${endColour}\n"
      elif [[ -x "$(command -v pacman)" ]]; then
        echo "installing..."
        isntalled=$(sudo pacman -Sy openvpn)
        ps2Id=$!
        wait $psId2
        echo -e "\n${purpleColour}[*] Succesfully installed in arch based!${endColour}\n"
      fi
    else
      echo -e "\n${redColour}[!] No package installed... aborting!\n ${endColour}"
      exit 1
    fi
  }
	echo -e "\n ${yellowColour}[+]${endColour} ${grayColour}Starting connection...."${endColour}
	sleep 1.5
	check=$(
		sudo openvpn --config $ovpnFile --daemon >/dev/null 2>&1
		echo $?
	)
	if [ "$check" -eq 0 ]; then
		echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Established connection"${endColour}
	else
		echo -e ${redColour}"\n [!] Connection could not be established"${endColour}
	fi
}

function disConnect() {
	psId=$(pgrep openvpn 2>/dev/null)
	check=$(
		sudo kill $psId 2>/dev/null
		echo $?
	)
	if [ "$check" -eq 0 ]; then
		echo -e "\n ${yellowColour}[+]${endColour} ${grayColour}Turning off connection...."${endColour}
		sleep 1.5
	else
		echo -e "\n ${redColour}[!] There is not an openvpn process running"${endColour}
	fi
}

declare -i parameter_counter=0

while getopts "cdh:" arg; do
	case $arg in
	c) let parameter_counter+=1 ;;
	d) let parameter_counter+=2 ;;
	h) let parameter_counter+=3 ;;
	esac
done

if [ $parameter_counter -eq 1 ]; then
	Connect
elif [ $parameter_counter -eq 2 ]; then
	disConnect
elif [ $parameter_counter -eq 3 ]; then
	helpPanel
else
	helpPanel
fi
