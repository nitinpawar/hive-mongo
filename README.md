hive-mongo
==========

This is a script which uses mongoimport to import data from a hive query 
to a mongodb.

There is a mongo-hive connector already existing but at the current state it 
does NOT support secure mongo clusters so I had to write this. 

Mandatory to have mongoimport on path
rest of the help if provided on shell script

./aggregateAndExport.sh -f <csv_file> -q <hive_query_file> -H <mongo_host> -P <port> -u <username> -p <passwd> ...
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
