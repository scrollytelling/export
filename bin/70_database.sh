#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

if [ $# -eq 0 ]
then
	echo "This script exports an account-specific slice from the Scrollytelling database."
	echo
	echo "Pass the account cname you wish to export as parameter."
	echo "Usage: $0 <cname>"
	echo "  e.g. $0 stories.example.com"
	echo
	exit 1
fi

set -vx
cname=$1
database="${cname//\./_}"

mysql -uroot -e "CREATE DATABASE IF NOT EXISTS \`${database}\`"
mysqldump --opt --user=root scrollytelling_development | mysql -uroot $database
mysql -uroot $database < step_5_database/cascade.sql
mysql -uroot -e "DELETE pageflow_accounts, pageflow_themings FROM pageflow_themings INNER JOIN pageflow_accounts ON pageflow_themings.account_id = pageflow_accounts.id WHERE cname <> '${cname}';" $database
mysql -uroot $database < step_5_database/strip.sql
mysqldump --opt -uroot -r "${database}.sql" $database
