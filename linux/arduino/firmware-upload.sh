#!/bin/sh


PROGNAME=$(basename $0)

error_exit ()
{

#	----------------------------------------------------------------
#	Function for exit due to fatal program error
#		Accepts 1 argument:
#			string containing descriptive error message
#	----------------------------------------------------------------


	echo "${PROGNAME}: ${1:-"Unknown Error"}" 1>&2
	exit 1
}

cd $1  || error_exit "$LINENO:"
#the first time you call 'ino upload' it has to configure itself. That takes longer and interferes with the reset. therefore we start it before hand and let it fail.
echo Setting up uploader 1>&2
#/opt/openrov/linux/reset.sh 1>&2
#ino upload -m atmega328 -p /dev/ttyO1 1>&2 

COUNTER=0
OUTPUT=`ino upload -p /dev/ttyO1 2>&1`
#OUTPUT=`avrdude -P /dev/ttyO1 -c arduino -D -vvvv -p m328p -U flash:w: .build/uno/firmware.hex 2>&1`
while [ $COUNTER -lt 9 ]; do
        echo $COUNTER
        (sleep 0.0$COUNTER && /opt/openrov/linux/reset.sh) & 1>&2
        avrdude -P /dev/ttyO1 -c arduino -D -v -p m328p -U flash:w:.build/uno/firmware.hex 2>&1

#	/opt/openrov/linux/reset.sh 1>&2
#	sleep 0.4
#        echo $OUTPUT  |  grep "bytes of flash verified"
	if [ $? -eq 0 ] 
		then
			echo upload successfull! 1>&2
			#echo $OUTPUT 1>&2
			exit 0
		fi
	COUNTER=`expr $COUNTER + 1`
	echo upload failed, trying again. 1>&2
#	echo $OUTPUT 1>&2
#	sleep 1
done
error_exit "Failed to upload after numerous tries. Aborting."
