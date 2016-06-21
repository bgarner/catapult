#!/bin/bash

#################################################

# General deploy script.  Depends on
# environment-specific script in .catapult/ dir

#################################################

set -e
CATAPULT_ENV_DIR=.catapult

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

catapultinit ()
{
	echo "Creating a catapult config file in .catapult..."

	if [[ -d "${CATAPULT_ENV_DIR}" && ! -L "${CATAPULT_ENV_DIR}" ]] ; then
 		:
	else
		echo "Creating .catapult directory"
		mkdir .catapult
	fi

	echo ""
	tput bold
	echo "Project Setup"
	tput sgr0

	echo "Type the name of your app, followed by [ENTER]:"
	read APP_NAME

	echo "Environment name? (e.g. production, testing, integration, etc)  [ENTER]:"
	read CONFIG_TYPE
	cd .catapult
	touch $CONFIG_TYPE.catapult
	echo -e '#################################################' >> $CONFIG_TYPE.catapult
	echo -e '' >> $CONFIG_TYPE.catapult
	echo -e  '#' $CONFIG_TYPE 'environment config for' $APP_NAME >> $CONFIG_TYPE.catapult
	echo -e  '' >> $CONFIG_TYPE.catapult
	echo -e  '#################################################' >> $CONFIG_TYPE.catapult
	echo -e  '' >> $CONFIG_TYPE.catapult
	echo -e  'APP_NAME="'$APP_NAME'"' >> $CONFIG_TYPE.catapult

	echo -e '' >> $CONFIG_TYPE.catapult
	echo -e '# Domain Config' >> $CONFIG_TYPE.catapult
	echo ""
	tput bold
	echo "Server Details"
	tput sgr0

	echo "List your server IPs or Hosts, seperated by SPACE  [ENTER]:"
	read DEPLOY_SERVER
	echo -e 'DEPLOY_SERVER=('$DEPLOY_SERVER')' >> $CONFIG_TYPE.catapult

	echo "What's your domain? (e.g. project.yourdomain.com or yourdomain.com)  [ENTER]:"
	read DEPLOY_HOST
	echo -e  'DEPLOY_HOST='$DEPLOY_HOST >> $CONFIG_TYPE.catapult

	echo "Path to deploy to?  [ENTER]:"
	read DEPLOY_PATH
	echo -e  'DEPLOY_PATH='$DEPLOY_PATH >> $CONFIG_TYPE.catapult

	echo "User to perform deploy (must have SSH access to all of your servers)  [ENTER]:"
	read DEPLOY_USER
	echo -e 'DEPLOY_USER='$DEPLOY_USER >> $CONFIG_TYPE.catapult

	echo "User to perform COMPOSER commands  [ENTER]:"
	read COMPOSER_USER
	echo -e 'COMPOSER_USER='$COMPOSER_USER >> $CONFIG_TYPE.catapult

	echo "User who should own APACHE [ENTER]:"
	read APACHE_USER
	echo -e 'APACHE_USER='$APACHE_USER >> $CONFIG_TYPE.catapult

	echo "Command to restart APACHE [ENTER]:"
	read APACHE_RESTART
	echo -e 'APACHE_RESTART="'$APACHE_RESTART'"' >> $CONFIG_TYPE.catapult

	echo "Command to get status of APACHE [ENTER]:"
	read APACHE_RESTART
	echo -e 'APACHE_STATUS="'$APACHE_STATUS'"' >> $CONFIG_TYPE.catapult

	echo -e '' >> $CONFIG_TYPE.catapult
	echo -e '# Git Options' >> $CONFIG_TYPE.catapult
	echo ""
	tput bold
	echo "Git Options"
	tput sgr0
	echo "Branch to use for deploy?  [ENTER]:"
	read BRANCH
	echo -e 'BRANCH='$BRANCH >> $CONFIG_TYPE.catapult

	echo -e '' >> $CONFIG_TYPE.catapult
	echo -e '# Database Stuff' >> $CONFIG_TYPE.catapult
	echo ""
	tput bold
	echo "Database Stuff"
	tput sgr0
	echo "Database name?  [ENTER]:"
	read DATABASE
	echo -e 'DATABASE='$DATABASE >> $CONFIG_TYPE.catapult
	echo "Database host?  [ENTER]:"
	read MYSQL_HOST
	echo -e 'MYSQL_HOST='$MYSQL_HOST >> $CONFIG_TYPE.catapult
	echo "Database user?  [ENTER]:"
	read MYSQL_USER
	echo -e 'MYSQL_USER='$MYSQL_USER >> $CONFIG_TYPE.catapult
	echo "Database password?  [ENTER]:"
	read MYSQL_PASS
	echo -e 'MYSQL_PASS='$MYSQL_PASS >> $CONFIG_TYPE.catapult	
	echo "Want to run 'migrate:reset' (y/n)?  [ENTER]:"
	read MIGRATION_REFRESH
	if [ $MIGRATION_REFRESH == "y" ]; then
		echo -e 'MIGRATION_REFRESH=true' >> $CONFIG_TYPE.catapult
	else
		echo -e 'MIGRATION_REFRESH=false' >> $CONFIG_TYPE.catapult
	fi
	echo "Want to run 'db:seed' (y/n)?  [ENTER]:"
	read SEEDER
	if [ $SEEDER == "y" ]; then
		echo -e 'SEEDER=true' >> $CONFIG_TYPE.catapult
	else
		echo -e 'SEEDER=false' >> $CONFIG_TYPE.catapult
	fi	
	echo "Want to execute an SQL script (y/n)?  [ENTER]:"
	read EXEC_SQL
	if [ $EXEC_SQL == "y" ]; then
		echo -e 'EXEC_SQL=true' >> $CONFIG_TYPE.catapult
		echo "Script file name? (expected to be in <project_root>/sql)  [ENTER]:"
		read EXEC_SQL_FILE
		echo -e 'EXEC_SQL_FILE='$EXEC_SQL_FILE >> $CONFIG_TYPE.catapult
	else
		echo -e 'EXEC_SQL=false' >> $CONFIG_TYPE.catapult
		echo -e 'EXEC_SQL_FILE=null' >> $CONFIG_TYPE.catapult
	fi	

	echo -e '' >> $CONFIG_TYPE.catapult
	echo -e '# Testing Stuff' >> $CONFIG_TYPE.catapult
	echo ""
	tput bold
	echo "Testing Stuff"
	tput sgr0	
	echo "Want to ping your project's domain (y/n)?  [ENTER]:"
	read PING_TEST
	if [ $PING_TEST == "y" ]; then
		echo -e 'PING_TEST=true' >> $CONFIG_TYPE.catapult
	else
		echo -e 'PING_TEST=false' >> $CONFIG_TYPE.catapult
	fi
	echo "Want to curl some URLs (y/n)?  [ENTER]:"
	read CURL_TEST
	if [ $CURL_TEST == "y" ]; then
		echo -e 'CURL_TEST=true' >> $CONFIG_TYPE.catapult
		echo "List some URLs to test, seperated by spaces (e.g. /login /whatever/resource)  [ENTER]:"
		read TEST_URLS
		echo -e 'TEST_URLS=('$TEST_URLS')' >> $CONFIG_TYPE.catapult
	else
		echo -e 'CURL_TEST=false' >> $CONFIG_TYPE.catapult
		echo -e 'TEST_URLS=' >> $CONFIG_TYPE.catapult
	fi	

	echo -e '' >> $CONFIG_TYPE.catapult
	echo -e '# Clean Up' >> $CONFIG_TYPE.catapult
	echo ""
	tput bold
	echo "Clean Up"
	tput sgr0	
	echo "Verbose cleanup -- this can be pretty verbose (y/n)?  [ENTER]:"
	read CLEANUP_VERBOSE
	if [ $CLEANUP_VERBOSE == "y" ]; then
		echo -e 'CLEANUP_VERBOSE=true' >> $CONFIG_TYPE.catapult
	else
		echo -e 'CLEANUP_VERBOSE=false' >> $CONFIG_TYPE.catapult
	fi
	echo "List files or folders your want to delete after a delpoy, seperated by SPACE  [ENTER]:"
	read CLEANUP
	echo -e 'CLEANUP=('$CLEANUP')' >> $CONFIG_TYPE.catapult

	echo ""
	tput bold
	echo "We're done!"
	tput sgr0	
	echo "Created '$CONFIG_TYPE.catapult' in .catapult. Feel free to edit this files as needed."
	echo "You can now deploy to that environment by typing 'catapult "$CONFIG_TYPE"'. Have fun!"
}

RELEASE_TIME=`date`
displayHeader                                                    

# Detect exactly 1 argument

if (($# == 1)); then

	if [ $1 == "init" ]; then
		catapultinit
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
	 echo 'git reset --hard $REMOTENAME/$BRANCH' &&
	 tput sgr0 &&
	 sudo git reset --hard $REMOTENAME/$BRANCH && 

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
	 echo 'sudo chown -R $COMPOSER_USER:$COMPOSER_USER $DEPLOY_PATH/vendor ' &&
	 echo 'sudo chown -R $COMPOSER_USER:$COMPOSER_USER storage ' &&
	 tput sgr0 &&
	 sudo chown -R $COMPOSER_USER:$COMPOSER_USER $DEPLOY_PATH/vendor/ &&
	 sudo chown -R $COMPOSER_USER:$COMPOSER_USER storage/ &&

	 tput setaf 6 &&
	 echo 'composer install' &&
	 tput sgr0 &&
	 cd $DEPLOY_PATH && 
	 composer install &&
	 php artisan view:clear &&
	 php artisan cache:clear &&
	 
	 tput setaf 6 &&
	 echo 'sudo chown -R $APACHE_USER:$APACHE_USER vendor/' &&
	 echo 'sudo chown -R $APACHE_USER:$APACHE_USER storage' &&
	 tput sgr0 &&
	 sudo chown -R $APACHE_USER:$APACHE_USER vendor/ &&
	 sudo chown -R $APACHE_USER:$APACHE_USER storage/ &&

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
	 echo '$APACHE_RESTART' &&
	 tput sgr0 &&
	 $APACHE_RESTART &&

	 tput setaf 6 &&
	 echo 'APACHE STATUS' &&
	 tput sgr0 && 

	 $APACHE_STATUS &&

	 sudo chmod 777 $DEPLOY_PATH/resources/views/site/includes/release-date.blade.php &&
	 > $DEPLOY_PATH/resources/views/site/includes/release-date.blade.php &&
	 
	 if [ $DEPLOY_TYPE == 'dev' ]; then
	 	echo $RELEASE_TIME - $REMOTENAME/$BRANCH >> $DEPLOY_PATH/resources/views/site/includes/release-date.blade.php
	 else
	 	echo $RELEASE_TIME >> $DEPLOY_PATH/resources/views/site/includes/release-date.blade.php
	 fi

	 tput setaf 6 &&
	 echo 'Updated time stamp in footer' &&
	 tput sgr0 &&

	 tput bold &&
	 echo'' &&
	 tput setaf 4 &&
	 tput rev &&
	 echo '    CLEAN UP                                           ' &&
	 tput sgr0 &&	

	 if [ $PERFORM_CLEANUP == 'true' ]; then
		 cd $DEPLOY_PATH 
		 tput setaf 1
		 echo "Deleting CLEANUP files"
		 if [ $CLEANUP_VERBOSE == 'true' ]; then
		 	sudo rm -rfv $DEPLOY_PATH/"${CLEANUP[@]}"	
		 else 
		 	sudo rm -rf $DEPLOY_PATH/"${CLEANUP[@]}"
		 fi
	 else
	 	tput setaf 1 
	 	echo "-- Skipping Cleanup --" 
	 fi
	 
	 tput sgr0 &&
	 echo 'Deplyed at: ' $RELEASE_TIME && 
	
	 tput setaf 6 &&
	 echo 'PERMISSIONS AND OWNERS' &&
	 tput sgr0 && 
	
	 sudo chmod -R 775 $DEPLOY_PATH &&
	 echo -e '    \xE2\x9C\x93 ' '775 on '$DEPLOY_PATH &&
	 
	 sudo chown -R $APACHE_USER:$APACHE_USER $DEPLOY_PATH &&
	 echo -e '    \xE2\x9C\x93 ' 'storage owned by $APACHE_USER:$APACHE_USER' &&
	 echo '' &&

	 cd $DEPLOY_PATH &&
	 tput bold &&
	 sudo php artisan up &&
	 tput sgr0 && 

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



