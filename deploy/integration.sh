#################################################

# Environment-specific script

# sourced by deploy.sh

#################################################

APP_NAME="FGL Portal"

displayHeader ()
{
	clear
	tput bold
	tput setaf 2
	echo '    ______________       ____             __        __'
	echo '   / ____/ ____/ /      / __ \____  _____/ /_____ _/ /'
	echo '  / /_  / / __/ /      / /_/ / __ \/ ___/ __/ __ `/ / '
	echo ' / __/ / /_/ / /___   / ____/ /_/ / /  / /_/ /_/ / /  '
	echo '/_/    \____/_____/  /_/    \____/_/   \__/\__,_/_/   '
	echo ''
	tput sgr0  
}

DEPLOY_SERVER=(ghost.dev)
DEPLOY_HOST=portal.ghost.dev
DEPLOY_PATH=/var/www/portal
DEPLOY_USER=root

#git stuff
BRANCH=master
TAG=null

#db stuff
DATABASE=fglportal
MYSQL_USER=root
MYSQL_PASS=root
MIGRATION_REFRESH=false
SEEDER=false
#sql file must be in 'sql' folder
EXEC_SQL=false
EXEC_SQL_FILE=install.sql

#testing stuff
CURL_TEST=false
PING_TEST=false

#cleanup
CLEANUP=("notes.txt" "whiteboard" "__design" "readme.md" "public/thumb" "public/wireframes")
CLEANUP_VERBOSE=false

