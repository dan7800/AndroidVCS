#!/bin/bash

### Description: Runs Androrisk.py on all .apk files in a given directory ($1)
### Note: All database calls are commented out for now.

#database={directory of DB.sqlite}
baseOutputDirectory=logs/AndroRiskOutput
androguardDirectory=androguard-1.9

logLocation=logs/androguard.log
date1=$(date +"%s")

### Remove the log if it is there
rm -f $logLocation

## Create the log
touch $logLocation

echo "AndroGuard Start:" `date` >> $logLocation

mkdir -p $baseOutputDirectory

# Check to make sure that an argument is actually passed in
EXPECTED_ARGS=1
if [ $# -ne $EXPECTED_ARGS ] 
then
	echo "Androguard requires 1 argument, the path to the location of the apk files"
fi

# # Get all .apk files in the input directory ($1)
FILES=$(find $1 -type f -name '*.apk')
for f in $FILES
do
    fileName=$(basename $f)
    fileName=${fileName//.apk/""} ### Remove the apk exension from the apkID 
  	
	echo "****Starting AndroGuard for:" $fileName `date` >> $logLocation
	
  	var=_AndroRisk
	OUTPUT_FILE=$baseOutputDirectory/$fileName$var.log

    ### Remove the output file if it exists
    rm -f $OUTPUT_FILE

	pushd ./$androguardDirectory
	./androrisk.py -m -i ../$f &>> ../$OUTPUT_FILE
	popd

	while read line;
	do
	
		if [[ $line == *VALUE* ]]
		then
			echo FUZZY RISK VALUE ${line#VALUE}

			APKFile=$(basename $f)
			APKFile=${APKFile//.apk/""} ### Remove the apk exension from the apkID
	
			# TODO - Find way to get versionNum and appDataId here
			### Get the app/versionID here so that we only have to do it once
			#versionNum=?
			#appDataId=?
			
			#versionId=`sqlite3 database  "SELECT versionID FROM Version WHERE version_number='$versionNum' AND appdataID='$appDataId';"`
			
			fuzzyRiskNum=${line#VALUE}   #I am truncating the fuzzy risk number and making it an int
  			fuzzyRiskfloat=${fuzzyRiskNum/.*}
  			fuzzyRiskint=$((fuzzyRiskfloat))
  			
			echo "****Fuzzy Risk :" ${f#$PATH_TWO} ":" $fuzzyRiskint `date` >> $logLocation
			
			### Check to see if the VersionID exists in tool results  		
			#VersionResultsCount=`sqlite3 database  "SELECT count(*) FROM Vulnerability WHERE VersionID='$versionId';"`
			#if [[ $APKToolResultsCount -eq 0 ]]; then
				#sqlite3 database  "INSERT INTO Vulnerability (versionID,fuzzy_risk) VALUES ($versionId,$fuzzyRiskint);"
			#else
      			#sqlite3 database  "UPDATE Vulnerability SET fuzzy_risk=$fuzzyRiskint WHERE versionID=$versionId;"
			#fi
		elif [[ $line == ERROR* ]]
		then

			echo FUZZY RISK $line
		fi
	done < $OUTPUT_FILE
	
done

echo "AndroGuard Completed"

date2=$(date +"%s")
diff=$(($date2-$date1))
echo "AndroGuard Total Running Time $(($diff / 60)) minutes and $(($diff % 60)) seconds."  >> $logLocation
echo "AndoGuard End:" `date` >> $logLocation
