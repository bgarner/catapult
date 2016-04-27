#!/bin/bash

#################################################

# General deploy script.  Depends on

# environment-specific script in deploy/ dir

#################################################

set -e



# Detect exactly 1 argument

if (($# == 1)); then

# Include .sh from the deploy folder

DEPLOY_ENV=$1

DEPLOY_FILE=deploy/$DEPLOY_ENV.sh

if [ -f $DEPLOY_FILE ]; then

source $DEPLOY_FILE

else

echo "Could not find deploy file for $DEPLOY_ENV environment,

  it should be located in $DEPLOY_FILE"

exit 1

fi

displayHeader                                                    
                                                         
echo "Deploying $APP_NAME to $DEPLOY_ENV environment."

else

echo "Usage: catapult.sh "

exit 1

fi

RELEASE_TIME=`date`


# From local machine, get hash of the head of the desired branch

# Required to checkout the branch - is there a better way to do this?

for SERVER in ${DEPLOY_SERVER[@]}

do
                                                                                             
echo "Deploying on $SERVER"

ssh -t $DEPLOY_USER@$SERVER "cd $DEPLOY_PATH &&

	 php artisan down &&

	 tput bold &&
	 echo'' &&
	 tput setaf 4 &&
	 tput rev &&
	 echo '    GIT                                                ' &&
	 tput sgr0 &&	

	 tput setaf 6 &&
	 echo 'git fetch --all' &&
	 tput sgr0 &&
	 git fetch --all &&

	 tput setaf 6 &&
	 echo 'git reset --hard origin/$BRANCH' &&
	 tput sgr0 &&
	 git reset --hard origin/$BRANCH && 

	 tput setaf 6 &&
	 echo 'git checkout $BRANCH' &&
	 tput sgr0 &&
	 git checkout $BRANCH &&

	 tput setaf 6 &&
	 echo 'git pull --rebase' &&
	 tput sgr0 &&
	 git pull --rebase &&

	 tput bold &&
	 echo'' &&
	 tput setaf 4 &&
	 tput rev &&
	 echo '    COMPOSER                                           ' &&
	 tput sgr0 &&

	 tput setaf 6 &&
	 echo 'sudo chown -R bgarner:bgarner vendor ' &&
	 echo 'sudo chown -R bgarner:bgarner storage ' &&
	 tput sgr0 &&
	 sudo chown -R bgarner:bgarner vendor &&
	 sudo chown -R bgarner:bgarner storage &&

	 tput setaf 6 &&
	 echo 'composer install' &&
	 tput sgr0 &&
	 runuser -l bgarner -c 'cd /var/www/portal && composer install' &&
	 
	 tput setaf 6 &&
	 echo 'sudo chown -R apache:apache vendor' &&
	 echo 'sudo chown -R apache:apache storage' &&
	 tput sgr0 &&
	 sudo chown -R apache:apache vendor &&
	 sudo chown -R apache:apache storage &&

	 tput bold &&
	 echo'' &&
	 tput setaf 4 &&
	 tput rev &&
	 echo '    DB MIGRATION                                       ' &&
	 tput sgr0 &&		

	 if [ $MIGRATION_REFRESH == 'true' ]; then
	 	tput setaf 6
	 	echo 'php artisan migrate:reset'
	 	tput sgr0				 	
	 	php artisan migrate:reset
	 fi

	 tput setaf 6 &&
	 echo 'php artisan migrate --force' &&
	 tput sgr0 &&
	 php artisan migrate --force &&				 			 

	 if [ $SEEDER == 'true' ]; then
	 	tput setaf 6
	 	echo 'php artisan db:seed'
	 	tput sgr0				 	
	 	php artisan db:seed
	 fi

	 if [ $EXEC_SQL == 'true' ]; then
	 	tput setaf 6
	 	echo 'mysql -u$MYSQL_USER -p$MYSQL_PASS $DATABASE < $EXEC_SQL_FILE'
	 	tput sgr0	
	 	cd $DEPLOY_PATH/sql			 	
	 	mysql -u$MYSQL_USER -p$MYSQL_PASS $DATABASE < $EXEC_SQL_FILE
	 	cd $DEPLOY_PATH
	 fi				 

	 tput bold &&
	 echo'' &&
	 tput setaf 4 &&
	 tput rev &&
	 echo '    APACHE                                             ' &&
	 tput sgr0 &&				 

	 tput setaf 6 &&
	 echo 'sudo systemctl restart httpd.service' &&
	 tput sgr0 &&
	 sudo systemctl restart httpd.service &&
	 sudo systemctl -q status httpd.service &&
	 
	 > /var/www/portal/resources/views/site/includes/release-date.blade.php &&
	 echo $RELEASE_TIME >> /var/www/portal/resources/views/site/includes/release-date.blade.php &&

	 tput bold &&
	 echo'' &&
	 tput setaf 4 &&
	 tput rev &&
	 echo '    CLEAN UP                                           ' &&
	 tput sgr0 &&	

	 cd $DEPLOY_PATH &&

	 tput setaf 1 &&
	 echo "Deleting CLEANUP files"
	 if [ $CLEANUP_VERBOSE == "true" ]; then
	 	rm -rfv "${CLEANUP[@]}"
	 else 
	 	rm -rf "${CLEANUP[@]}"
	 fi
	 
	 tput sgr0 &&

	 echo 'Deplyed at: ' $RELEASE_TIME && 

	 php artisan up &&

	 tput bold &&
	 tput setaf 1 &&
	 exit"
done

tput bold
echo''
tput setaf 4
tput rev
echo '    VERIFICATION                                       '  
tput sgr0 

echo "Checking host: " $DEPLOY_HOST 
echo''
if [ $PING_TEST == 'true' ]; then
	tput setaf 6 
	echo "ping..."
	tput sgr0 
	ping -c 3 $DEPLOY_HOST 
fi
echo''
if [ $CURL_TEST == 'true' ]; then
	tput setaf 6 
	echo "curl..."
	tput sgr0 
	time curl -I http://$DEPLOY_HOST | grep HTTP 
fi

tput bel
tput bold
echo ""
echo "*************************************************************" 
echo "***************     Finished successfully     ***************"
echo "*************************************************************" 
echo ""



