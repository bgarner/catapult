#!/bin/bash

#################################################

# General deploy script.  Depends on
# environment-specific script in .catapult/ dir

#################################################

set -e

#source func.sh

displayHeader ()
{
	clear
	tput bold
	tput setaf 5
	echo '               __                      .__   __   '
	echo '  ____ _____ _/  |______  ______  __ __|  |_/  |_ '
	echo '_/ ___\\__  \\   __\__  \ \____ \|  |  \  |\   __\'
	echo '\  \___ / __ \|  |  / __ \|  |_> >  |  /  |_|  |  '
	echo ' \___  >____  /__| (____  /   __/|____/|____/__|  '
	echo '     \/     \/          \/|__|    '
	echo ''
	tput sgr0  
}

RELEASE_TIME=`date`
displayHeader                                                    

# Detect exactly 1 argument

if (($# == 1)); then

	if [ $1 == "init" ]; then
		echo "let's run the init!"
		exit 1
	fi

	# Include .sh from the deploy folder
	DEPLOY_ENV=$1
	DEPLOY_FILE=.catapult/$DEPLOY_ENV.catapult

	if [ -f $DEPLOY_FILE ]; then
		source $DEPLOY_FILE
	else
		echo "Could not find deploy file for $DEPLOY_ENV environment, it should be located in $DEPLOY_FILE"
	exit 1
fi

testURLs ()
{
	for URL in ${TEST_URLS[@]}
	do
		echo "Checking http://$DEPLOY_HOST$URL ..."
		HTTP_STATUS="$(curl -IL --silent http://$DEPLOY_HOST$URL | grep HTTP )"; 
		if [[ $HTTP_STATUS == *"200"* ]]
		then
			tput setaf 2
			echo -e "\xE2\x9C\x93 " "${HTTP_STATUS}";
			tput sgr0
		else
		  	tput setaf 1
		  	echo -e "\xE2\x98\xA0 " "${HTTP_STATUS}";
		  	tput sgr0
		fi
	done
}

sectionTitle ()
{
	 tput bold
	 echo '' 
	 tput setaf 4 
	 tput rev 
	 echo '    '$1'                                               ' &&
	 tput sgr0 		
}


                                                         
echo "Deploying $APP_NAME to $DEPLOY_ENV environment."

else

echo "Usage: catapult.sh "

exit 1

fi


# From local machine, get hash of the head of the desired branch

# Required to checkout the branch - is there a better way to do this?

for SERVER in ${DEPLOY_SERVER[@]}

do
                                                                                             
echo "Deploying on $SERVER"

ssh -t $DEPLOY_USER@$SERVER "cd $DEPLOY_PATH &&

	 sudo php artisan down &&

	 tput bold &&
	 echo'' &&
	 tput setaf 4 &&
	 tput rev &&
	 echo '    GIT                                                ' &&
	 tput sgr0 &&

	 tput setaf 6 &&
	 echo 'Using Remote: ' &&
	 tput sgr0 &&
	 git remote -v &&

	 tput setaf 6 &&
	 echo 'git fetch --all' &&
	 tput sgr0 &&
	 sudo git fetch --all &&

	 tput setaf 6 &&
	 echo 'git reset --hard origin/$BRANCH' &&
	 tput sgr0 &&
	 sudo git reset --hard origin/$BRANCH && 

	 tput setaf 6 &&
	 echo 'git checkout $BRANCH' &&
	 tput sgr0 &&
	 sudo git checkout $BRANCH &&

	 tput setaf 6 &&
	 echo 'git pull --rebase' &&
	 tput sgr0 &&
	 sudo git pull --rebase &&

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
	 cd /var/www/portal && 
	 composer install &&
	 php artisan view:clear &&
	 php artisan cache:clear &&
	 
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
	 	sudo php artisan migrate:reset
	 fi

	 tput setaf 6 &&
	 echo 'php artisan migrate --force' &&
	 tput sgr0 &&
	 sudo php artisan migrate --force &&				 			 

	 if [ $SEEDER == 'true' ]; then
	 	tput setaf 6
	 	echo 'php artisan db:seed'
	 	tput sgr0				 	
	 	sudo php artisan db:seed
	 fi

	 if [ $EXEC_SQL == 'true' ]; then
	 	tput setaf 6
	 	echo 'mysql -u$MYSQL_USER -p$MYSQL_PASS $DATABASE < $EXEC_SQL_FILE'
	 	tput sgr0	
	 	cd $DEPLOY_PATH/sql			 	
	 	sudo mysql -u$MYSQL_USER -p$MYSQL_PASS $DATABASE < $EXEC_SQL_FILE
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

	 tput setaf 6 &&
	 echo 'APACHE STATUS' &&
	 tput sgr0 && 

	 systemctl -q status httpd.service &&

	 sudo chmod 777 /var/www/portal/resources/views/site/includes/release-date.blade.php &&
	 > /var/www/portal/resources/views/site/includes/release-date.blade.php &&
	 echo $RELEASE_TIME >> /var/www/portal/resources/views/site/includes/release-date.blade.php &&

	 tput setaf 6 &&
	 echo 'Updated time stamp in footer' &&
	 tput sgr0 &&

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
	 	sudo rm -rfv "${CLEANUP[@]}"
	 else 
	 	sudo rm -rf "${CLEANUP[@]}"
	 fi
	 
	 tput sgr0 &&

	 echo 'Deplyed at: ' $RELEASE_TIME && 

	 tput bold &&
	 sudo php artisan up &&
	 tput sgr0 && 
	 
	 tput setaf 6 &&
	 echo 'PERMISSIONS AND OWNERS' &&
	 tput sgr0 && 

	 cd /var/www/portal &&
	 sudo chmod -R 775 . &&
	 echo -e '    \xE2\x9C\x93 ' '775' &&
	
	 sudo chown -R apache:apache . &&
	 echo -e '    \xE2\x9C\x93 ' 'apache:apache' &&
	 echo '' &&
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
	echo "PING TEST"
	tput sgr0 
	ping -c 3 $DEPLOY_HOST 
fi
echo''
if [ $CURL_TEST == 'true' ]; then
	tput setaf 6 
	echo "CURL TEST"
	tput sgr0 
	testURLs 
fi

tput bold
echo ""
echo "*************************************************************" 
echo "***************     Finished successfully     ***************"
echo "*************************************************************" 
echo ""



