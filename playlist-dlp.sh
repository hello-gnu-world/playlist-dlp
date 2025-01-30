#!/bin/sh

#Stores current working directory
dir="$(pwd)"
#Stores video quality for downloaded video
quality="720";

#Defines function that requires the user to input a yes or no answer
yesORno(){
while [[ "${answer,,}" != "no" ]] && [[  "${answer,,}" != "yes" ]] ;
do 
        read -r answer
        if [ "$(echo "$answer" | cut -b1)" == 'n' ];
        then
                answer='no';
        else
                answer='yes';
        fi
        if [[ "${answer,,}" != "no" ]] && [[  "${answer,,}" != "yes" ]];
        then
                echo -e "\nPlease enter 'yes' or 'no'."
        fi
done
}

install_dep(){
error="$?";
if [ "$error" == '1' ];
then
	echo "Package "$1" is required for this script to work. Would you like to download it?"
	yesORno
	if [ "$answer" == 'yes' ];
	then
		echo "Please input sudo password to update system and install packages."
		case "$2" in
			arch-based)
				sudo pacman -Syyu "$1";
				;;
			debian-based)
				sudo apt update; sudo apt upgrade; sudo apt install "$1";
				;;
		esac
	else
		echo "Required packages not installed. Exitting";
		exit;
	fi	
fi
}

#Checks user's distribution type and whether or not they have require packages to run this script
packageManager="$(apropos "package manager" | grep -o pacman | head -n1)";
#Asks the user if they desire install required packages, and installs them if yes
case "$packageManager" in
	pacman)
		pacman -Qi yt-dlp > /dev/null 2>&1;
		install_dep 'yt-dlp' 'arch-based';
		;;
	dpkg)
		dpkg -l yt-dlp > /dev/null 2>&1
		install_dep 'yt-dlp' 'debian-based';
		;;
	*)
		echo "This script currently only supports checking whether or not the propper package(s) are installed on debian and arch based systems. Ensure the proper packages are installed or else this script will not work!"
		;;
esac

while getopts 'd:p:n:q:h' OPTION; do
	case "$OPTION" in
		d)	
			#Assigns directory where playlist will be stored
			dir="$OPTARG";	
			;;
		p)	
			#Stores url of playlist that will be downloaded
			playlist="$OPTARG";
			;;
		n)
			#Assigns the name of the playlist to the commannd line argument
			playlistName="$OPTARG";
			;;
		q)
			case "$OPTARG" in
				144)
					quality="$OPTARG";
					;;
				240)
					quality="$OPTARG";
					;;
				360)
					quality="$OPTARG";
					;;
				480)
					quality="$OPTARG";
					;;
				720)
					quality="$OPTARG";
					;;
				1080)
					quality="$OPTARG";
					;;
				*)
					echo "$OPTARG is not a valid video quality";
					exit;
					;;
			esac
			;;
		h)
			#Displays help information about different command line arguments
			echo "Flags:
			-d | directory where playlist will be stored
			-p | url of playlist to be downloaded
			-n | name of playlist directory
			-q | quality of videos within playlist.
			
			Possible qualities:
			144
			240
			360
			480
			720
			1080";
			exit;
			;;
		*)
			#Directs user to "help" command line argument
			echo "Use -h for flag information."
			exit;
			;;
	esac
done

#Assigns name of playlist from site to name of playlist directory if not previously assigned
if [ "$playlistName" = '' ];
then
	playlistName="$(yt-dlp -I0 -o --get-filename --skip-download --no-warnings "$playlist" | tail -1 | cut -d ":" -f 2 | xargs)";
fi

#Checks if directory exists and exits if it does not
if [ ! -d "$dir" ];
then
	echo "$dir does not exist! Exitting...";
	exit;
fi

cd "$dir" || exit;

#Checks if directory with playlist name already exists, if not, creates it 
if [ ! -d "$playlistName" ];
then
	mkdir "$playlistName";
fi
#Enters playlist directory and downloads next video
cd "$playlistName" || exit;
yt-dlp -f "bestvideo[height<=$quality]+bestaudio/best[height<=$quality]" --yes-playlist "$playlist";
