#!/bin/bash

# View all JumpBox apps: http://www.jumpbox.com/go/virtualization?page=0

LOGDIR="." # Root logfile directory
LOGFILE="${LOGDIR}/jumpbox_check.log" # Logfile location
STORED="${LOGDIR}/stored_jumpboxes.txt" # Location of stored versions file
SAVETO="."  # No trailing slash required
UA="Mozilla/4.0 (compatible; MSIE 7; Windows NT 5.1" # User Agent
APPS=( deki knowledgetree lampd mysqld jasperbi sugarcrm5 joomla15 joomla cacti wordpress mediawiki openfire \
	drupal6 drupal dokuwiki moinmoin mantis orangehrm redmine magento nagios3 punbb rubyonrails alfresco liferay \
	lappd zenoss tikiwiki bugzilla glpi postgresqld moodle tracks pmwiki otrs trac vtigercrm silverstripe nagios \
	gallery sugarcrm phpbb openldap movabletype projectpier dimdim snaplogic )

log() {
	echo "`date` $*" >> $LOGFILE
}

error() {
	log "ERROR: $*"
}

fail() {
	log "ERROR: $*"
	exit 1
}

if [ "$1" = "create" ]; then
	rm -rf $STORED
	touch $STORED
	for i in "${APPS[@]}"
	do
		CURRENT=`curl -s --user-agent "$UA" http://www.jumpbox.com/app/${i} | grep "JumpBox Version" | awk '{print $3}'`
		if [ `echo $i | wc -m` -ge 8 ]; then
			echo -e "$i \t $CURRENT" >> $STORED
		else
			echo -e "$i \t \t $CURRENT" >> $STORED
		fi
	done
	exit 0
fi

log "======== Beginning JumpBox Update Check ========"

if [ ! -d $LOGDIR ]; then
	error "The \$LOGDIR directory does not exist!"
	fail "\$LOGDIR = $LOGDIR"
fi

if [ ! -d $SAVETO ]; then
	error "The \$SAVETO directory does not exist!"
	fail "\$SAVETO = $SAVETO"
fi

if [ ! -f $STORED ]; then
	error "Your list of stored JumpBoxes does not exist."
	error "Please create it and then rerun the script."
	fail "\$STORED = $STORED"
fi

for i in "${APPS[@]}"
do
	CURRENT=`curl -s --user-agent "$UA" http://www.jumpbox.com/app/${i} | grep "JumpBox Version" | awk '{print $3}'`
	URL="http://downloads2.jumpbox.com/${i}-${CURRENT}.zip"
	log "Checking for new JumpBox: $i"
	if [ `echo $i | wc -m` -ge 8 ]; then
		BIG=`grep -w $i $STORED | awk -F "\t" '{print $2}' | sed 's/ //g'`
		if [ "$BIG" == "$CURRENT" ]; then
			#log "JumpBox found! $i v${CURRENT}"
			log "JumpBox already stored. Skipping download."
		else
			log "New JumpBox found! $i v${CURRENT}"
			log "JumpBox updated! Starting download..."
			log "Getting: $URL"
			#curl -s -G -o $SAVETO/${i}-${CURRENT}.zip --user-agent "${UA}" $URL
			if [ $? -eq 0 ]; then
				log "Download complete!"
			else
				error "Download was unsuccessful!  Please check"
				error "the URL and try the download again."
			fi
			# TODO: add sed command to replace old version with this one in $STORED
		fi
	else
		SMALL=`grep -w $i $STORED | awk -F "\t" '{print $3}' | sed 's/ //g'`
		if [ "$SMALL" == "$CURRENT" ]; then
			#log "JumpBox found! $i v${CURRENT}"
			log "JumpBox already stored. Skipping download."
		else
			log "New JumpBox found! $i v${CURRENT}"
			log "JumpBox updated!  Starting download..."
			log "Getting: $URL"
			#curl -s -G -o $SAVETO/${i}-${CURRENT}.zip --user-agent "${UA}" $URL
			if [ $? -eq 0 ]; then
				log "Download complete!"
			else
				error "Download was unsuccessful!  Please check"
				error "the URL and try the download again."
			fi
			# TODO: add sed command to replace old version with this one in $STORED
		fi
	fi
	#sleep 15 #+-- Just to be nice to the server, sleep for 15s till next check
done

log "JumpBox update check completed!"

#EOF
