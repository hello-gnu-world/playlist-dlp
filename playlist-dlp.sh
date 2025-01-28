#!/bin/sh

#Stores current working directory
dir="$(pwd)"
#Stores video quality for downloaded video
quality="720";
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
