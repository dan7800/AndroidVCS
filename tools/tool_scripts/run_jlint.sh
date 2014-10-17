#!/bin/bash 
### Run Jlint on all files
### Will return a listing of defects & suggestions in the application.
### Usage
### ./run_jlint {directory of apkToJava output}?


logLocation=logs/jlint.log

### Remove the log if it is there
rm -f $logLocation

## Create the log
touch $logLocation

echo "Jlint Start:" `date` >> $logLocation

date1=$(date +"%s")


### Location of all files to be analyzed
inputDirectory=apkToJavaOutput/  ### Must have trailing space, or things will not work with a symlink


### Loop through all of the javaOutput folders
### Loop through all of the folders in the input directory
for i in $(find $inputDirectory -mindepth 1 -maxdepth 1 -type d ) 
									### mindepth ignore the top layer
									### Only examine the top layer
do

	echo "Begin Jlint Analyzing:" `echo $i` `date` >> $logLocation

	jlintCount=0 # Reset the count after each iteration
	### Loop through each of these folders and analyze each .class file
	
	FILES=$(find $i -type f -name '*.class')
	for f in $FILES
	do
		tempoutput=`jlint $f`

		### Check to make sure that tempoutput contains "Verifcation Completed"
		### if not, then skip it
        ### Note: Output this to a log if you want to pull this info into a database later
		if [[ $tempoutput =~ "Verification completed"* ]]
		then
			tempResults=`echo $tempoutput | sed -e "s/.*Verification completed: //;s/ reported messages.*//";`
            #echo $tempoutput
			#echo $tempResults
		fi
		jlintCount=$((jlintCount+tempResults))

	done
	
	### Add output to log file
	echo "JLint Count:" $jlintCount in $i `echo $i` `date` >> $logLocation	
	
	#### ADD THIS INFORMATION TO THE DATABASE
	#### JLint Value: $jlintCount 
	#### APK File: $i - still needs the .apk removed and version number added
	
	echo JLint Value: $jlintCount APK File: $i

	### Convert the file being analyzed to something usable
	APKFile=$(basename $i)
	APKFile=${APKFile//%apk/""} ### Remove the apk exension from the apkID

	
	#select from apk information the row id where apkid = filename
#rowid=`sqlite3 EvolutionOfAndroidApplications.sqlite  "SELECT rowid FROM ApkInformation WHERE ApkId='$APKFile';"`

	### Check to see if the APKID exists in tool results  		
#APKToolResultsCount=`sqlite3 EvolutionOfAndroidApplications.sqlite  "SELECT count(*) FROM ToolResults WHERE rowid='$rowid';"`

#if [[ $APKToolResultsCount -eq 0 ]]; then
#sqlite3 EvolutionOfAndroidApplications.sqlite  "INSERT INTO ToolResults (ApkId,JlintResult) VALUES ($rowid,$jlintCount);"
#else
#sqlite3 EvolutionOfAndroidApplications.sqlite  "UPDATE ToolResults SET JlintResult=$jlintCount WHERE ApkId=$rowid;"
#fi

done

echo "End Jlint Analyzing:" `echo $i` `date` >> $logLocation

date2=$(date +"%s")
diff=$(($date2-$date1))


echo "JLint Total Running Time $(($diff / 60)) minutes and $(($diff % 60)) seconds."  >> $logLocation
echo "Jlint End:" `date` >> $logLocation