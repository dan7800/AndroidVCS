#!/bin/bash 
### Run Android Lint on all files
### Will return a listing of defects & suggestions in the application.
### Usage
### ./run_androidlint {directory of github source repos}

#database={directory of DB.sqlite}

androidLintDirectory=sdk/tools

logLocation=logs/androidlint.log

### Remove the log if it is there
rm -f $logLocation

## Create the log
touch $logLocation

echo "Android Lint Start:" `date` >> $logLocation

date1=$(date +"%s")


### Location of all files to be analyzed
inputDirectory=$1


### Loop through all of the folders in the input directory
### mindepth/maxdepth, only examine the 1st level of directories in $inputDirectory
for i in $(find $inputDirectory -mindepth 1 -maxdepth 1 -type d )
do

	echo "Begin Android Lint Analyzing:" `echo $i` `date` >> $logLocation

	androidLintErrorCount=0
    androidLintWarningCount=0

    # Run the Android lint tool on the directory
    tempoutput=$(./$androidLintDirectory/lint $i)

### Get the last line of output containing the total number of errors/warnings
lastlineoutput=`echo $tempoutput | grep -o "[0-9] errors, [0-9]\+ warnings";`
echo $lastlineoutput

### Check to make sure that tempoutput contains "errors" and "warnings"
### if not, then skip it. Otherwise, grab the total number of errors/warnings found
### Note: Output this to a log if you want to pull this info into a database later
if [[ $lastlineoutput =~ .*"errors".* ]]
then
    androidLintErrorCount=`echo $lastlineoutput | sed -e "s/ errors.*//";`
    echo $androidLintErrorCount
fi

if [[ $lastlineoutput =~ .*"warnings".* ]]
then
    androidLintWarningCount=`echo $lastlineoutput | sed -e "s/.*errors, //;s/ warnings.*//";`
    echo $androidLintWarningCount
fi
	
	### Add output to log file
	echo "Android Lint Error Count:" $androidLintErrorCount in $i `date` >> $logLocation
    echo "Android Lint Warning Count:" $androidLintWarningCount in $i `date` >> $logLocation
	
	#### ADD THIS INFORMATION TO THE DATABASE
    ### Note: Still need a place to put these values in the database.

    # TODO - Find way to get versionNum and appDataId here
    ### Get the app/versionID here so that we only have to do it once
    #versionNum=?
    #appDataId=?
    #versionId=`sqlite3 database "SELECT versionID FROM Version WHERE version_number='$versionNum' AND appdataID='$appDataId';"`

	### Check to see if the versionID exists in the database already
    #APKToolResultsCount=`sqlite3 database  "SELECT count(*) FROM table WHERE rowid='$rowid';"`

    #if [[ $APKToolResultsCount -eq 0 ]]; then
        #sqlite3 database  "INSERT INTO table (VersionID,errorCount,warningCount) VALUES ($versionId,$androidLintErrorCount,$androidLintWarningCount);"
    #else
        #sqlite3 database  "UPDATE table SET errorCount=$androidLintErrorCount, warningCount=$androidLintWarningCount WHERE VersionID=$versionId;"
    #fi

done

echo "End Android Lint Analyzing:" `echo $i` `date` >> $logLocation

date2=$(date +"%s")
diff=$(($date2-$date1))


echo "Android Lint Total Running Time $(($diff / 60)) minutes and $(($diff % 60)) seconds."  >> $logLocation
echo "Android Lint End:" `date` >> $logLocation