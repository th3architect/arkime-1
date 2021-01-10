#!/bin/bash

err_msg () { printf '\033[0;31m[ ERROR ]\033[0m' && echo -e "\t"$(date)"\t"$BASH_SOURCE"\t"$1; }
warn_msg () { printf '\033[1;33m[ WARN ]\033[0m' && echo -e "\t"$(date)"\t"$BASH_SOURCE"\t"$1; }
info_msg () { printf '\033[0;36m[ INFO ]\033[0m' && echo -e "\t"$(date)"\t"$BASH_SOURCE"\t"$1; }

## INITIALIZE DATABASE & CREATE ADMIN USER ##
#
# initialize es database
info_msg "The elasticsearch database will be initialized.";
echo INIT | /data/moloch/db/db.pl http://elasticsearch:9200 init;

# set default creds if none specified
if [ -z $ARKIME_USER ]; then ARKIME_USER="root"; fi;
if [ -z $ARKIME_PSWD ]; then ARKIME_PSWD="arkime-pswd"; fi;

# create admin user
info_msg "Arkime admin:\t"$ARKIME_USER"\twas created with password:\t"$ARKIME_PSWD;

$ARKIME_DIR/bin/moloch_add_user.sh $ARKIME_USER "Arkime Admin" $ARKIME_PSWD --admin;

#'lost'21jn