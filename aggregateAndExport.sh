#!/bin/sh

export MONGO_HOME=/home/hive/mongo
export PATH=$PATH:$MONGO_HOME/bin

function help {
	echo "./aggregateAndExport.sh -f <csv_file> -q <hive_query_file> -H <mongo_host> -P <port> -u <username> -p <passwd> ...
	options:	-f csv_file	If csv file is present then used, else query is mandatory
					query output is rewritten to file and exported to mongohq
			-q query_file	a file containing hive query to execute
			-H hostname 	mongohq hostname
			-P port		mongohq connection port
			-u username	username to connect
			-p password	password to connect
			-d database	database to use
			-c collection	collection to write into
			-F fileds 	comma separated list of fields being inserted
		"
	exit 1
}

function isSet() {
	if [[ ! -n "$1" ]] 
	then
		echo " some variable is not set"
		exit 2
	fi
}

function checkFile() {
	if [ ! -f $1 ]
	then
		return 1
	else
		return 0
	fi
}
if [ $# -eq 0 ]
then
	help
fi

while [ $# -gt 0 ]
do
    case "$1" in
	-f)	filename="$2"; shift;;
	-q)	queryfile="$2"; shift;;
	-H)	host="$2"; shift;;
	-P)	port="$2"; shift;;
	-u)	username="$2"; shift;;
	-p)	password="$2"; shift;;
	-d)	database="$2"; shift;;
	-c)	collection="$2"; shift;;
	-F)	fields="$2"; shift;;
	-*)	help;;
	*)	break;;		# terminate while loop
    esac
    shift
done
isSet $filename 
isSet $host
isSet $port 
isSet $username 
isSet $password 
isSet $database 
isSet $collection 
isSet $fields

checkFile $filename
filePresent=$?

if [ $filePresent -eq 0 ]
then
	echo "	CSV file present, not running hive query"
	echo "	uploading to mongohq"
	runQuery=False
else
	runQuery=True
fi

if [ $runQuery == "True" ]
then
	echo "need to run query to generate csv"
	isSet $queryfile
	checkFile $queryfile
	qExists=$?
	if [ $qExists -ne 0 ]
	then
		echo "Query file does not exists"
		echo "Quitting ...."
		exit 1
	fi
	hive -f $queryfile | grep -v "Moved to trash: hdfs://" > $filename
	if [ $? != 0 ]
	then
		echo "Hive failed"
		echo "Quitting .... "
		exit 1
	fi
fi

tmpFile=$RANDOM
cat $filename | tr "\t" "," > /tmp/$tmpFile
mv /tmp/$tmpFile $filename

echo "Starting mongo upload"

mongoimport --host $host --port $port --username $username --password $password  --db $database --collection $collection --type csv --file $filename --fields $fields
