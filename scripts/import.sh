#!/bin/bash

err_msg () { printf '\033[0;31m[ ERROR ]\033[0m' && echo -e "\t"$(date)"\t"$BASH_SOURCE"\t"$1; }
warn_msg () { printf '\033[1;33m[ WARN ]\033[0m' && echo -e "\t"$(date)"\t"$BASH_SOURCE"\t"$1; }
info_msg () { printf '\033[0;36m[ INFO ]\033[0m' && echo -e "\t"$(date)"\t"$BASH_SOURCE"\t"$1; }

FLAG="/arkime/bin/flags"

info_msg "[ Arkime Import ] has been started."

## WAIT FOR ELASTICSEARCH TO COME ONLINE ##
#
while [ "$(curl elasticsearch:9200/_cluster/health?pretty 2> /dev/null | grep status | awk -F '"' '{print $4}')" != "green" ]; do 
  warn_msg "Waiting for ElasticSearch to come online..."; 
  sleep 5; 
done

info_msg "ElasticSearch is online."

## CONFIGURE ARKIME & CREATE USER ##
#
if [ -e "$FLAG/conf_arkime" ]; then

  /arkime/bin/config.sh;

  ## WAIT FOR INIT-DB ##
  #
  while [ "$(curl viewer:8005 2> /dev/null)" != "Unauthorized" ]; do 
    warn_msg "Waiting for [ Arkime Viewer ] to come online...";
    sleep 5; 
  done;

  info_msg "[ Arkime Viewer ] is online.";

  ## CREATE USER ## 
  #
  /arkime/bin/add-user.sh;

  rm $FLAG/conf_arkime;
fi

## ENABLE PCAP DOWNLOAD FROM VIEWER ##
#
info_msg "Enabling access to imported .pcap files for [ Arkime Viewer ] over port 8005."
cd $ARKIME_DIR/viewer && ../bin/node ./viewer.js -c ../etc/config.ini | tee -a /arkime/log/$(hostname).log > /dev/null &

info_msg "[ Arkime Import ] is now watching %root%/import/ for .pcap files."

## RUN IMPORT CHECK EVERY 60 SECONDS ##
#
while :; do

  ## CHECK FOR PCAP FILES ##
  #
  if [ ! -z $(ls /import/*.pcap 2> /dev/null) ]; then
  
    ## EAT PCAP FOR BREAKFAST ##
    #
    for PCAP_FILE in $(ls /import | grep '\.pcap'); do
      
      info_msg "Importing: "$PCAP_FILE;
      mv /import/$PCAP_FILE /arkime/data/$PCAP_FILE;
      chmod +r /arkime/data/$PCAPFILE;
      $ARKIME_DIR/bin/moloch-capture -r /arkime/data/$PCAP_FILE | tee -a /arkime/log/$(hostname).log > /dev/null;
  
    done;
    info_msg "Import complete. Now waiting for more .pcap files...";
  fi;

  sleep 60;

done

err_msg "Powering down [ Arkime Import ]..."

#'lost'21jn
