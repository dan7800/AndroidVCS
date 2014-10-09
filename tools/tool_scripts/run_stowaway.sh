#!/bin/bash

### Description: Invokes the stowaway application on the a directory of .apk files ($1)
###	and then records the over and under-privileges into the application database.
### Note: All database calls are commented out for now. 

	logLocation=logs/stowaway.log
	#database={directory of DB.sqlite}
	stowawayDirectory=Stowaway-1.2.4

	### Remove the log if it is there
	rm -f $logLocation

	## Create the log
	touch $logLocation

	echo "Stowaway Start:" `date` >> $logLocation

	date1=$(date +"%s")

	inputDir=$1
	outputDir=StowawayOutput/

	### clear just in case, this will prevent errors
	rm -rf $outputDir

	### Check to see if the contents of the file exist in the permission table. If not, then add them.
	### Inputs:
	### 1) OverPermission or UnderPermission (which input is being examined)
	### 2) apkFileName
	###	3) versionID
	function CheckAndAddOverAndUnderPrivs { 
		filetype=$1 # over or under priv
		versionId=$3

        echo $2/$filetype >> ../$logLocation

		### First check to make sure that the file exists
		if [ -f $2/$filetype ];
		then
			### The file exists, so now loop through it and make sure the privs exist in the database
			filename="$2/$filetype"

			### Add empty last line to the file. This is messy.
			sed -i '' -e '$a\' $filename
			while read -r line
			do
    			priv=$line
    			echo $priv >> ../$logLocation
    			### IF there is a space, then ignore it.
				if [ "$priv" == "${priv//[\' ]/}" ]
				then 
					echo $name
					
					### First make sure the permission exists in the list of available permissions
					#addIfNotExistsDBPermissions $priv

					### Get the permissionID from the table
					#pid=`sqlite3 ../database  "SELECT pid FROM Permission WHERE name='$priv';"`
				
					### check to see if the record exists
					#count=`sqlite3 ../database  "SELECT count (PermissionID) as permissionidcount FROM $filetype WHERE PermissionID='$pid' and VersionID='$versionId'"`

					### If the value does not exist, add it to the table
					#if [ $count -eq 0 ]
					#then
						#sqlite3 ../../database "INSERT INTO $filetype (PermissionID, VersionID) VALUES ($pid, '$versionId');"
						#echo Add $pid - $versionId to $filetype
					#fi
				fi

				done < "$filename"

		fi


	} 


	### Check to see if the permission exists in the DB, if not then add it. Otherwise, do nothing.
	#function addIfNotExistsDBPermissions {

		### Check to see if the value exists in the DB
		#count=`sqlite3 ../../database  "SELECT count (name) as NameCount FROM Permission WHERE name='$1';"`
		#if [ $count -eq 0 ]
		#then
			## The value does not exist, add it to the table
			#sqlite3 ../../database  "INSERT INTO Permission (name) VALUES ('$1');"
			#echo Add $1 to Permissions
		#fi
	#}

	# Get all .apk files in the input directory ($1)
    FILES=$(find $inputDir -type f -name '*.apk')
	
	for f in $FILES
	do
		echo $f >> $logLocation

		## Run Stowaway on each .apk file
		APKFile=$(basename $f)
		APKFile=${APKFile//.apk/""} ### Remove the apk exension from the apkID
		echo "Begin analyzing: " $APKFile `date` >> $logLocation

		cd $stowawayDirectory
		mkdir -p $outputDir/$APKFile


		# TODO - Find way to get versionNum and appDataId here
		### Get the app/versionID here so that we only have to do it once	
		#versionNum=?
		#appDataId=?
			
		#versionId=`sqlite3 database  "SELECT versionID FROM Version WHERE version_number='$versionNum' AND appdataID='$appDataId';"`

		./stowaway.sh ../$f $outputDir/$APKFile
		
		### Check to see if Underprivilege file exists
		CheckFor=UnderPermission
   		CheckAndAddOverAndUnderPrivs $CheckFor $outputDir$APKFile versionId
		
		### Check to see if Overprivilege file exists
		CheckFor=OverPermission
   		CheckAndAddOverAndUnderPrivs $CheckFor $outputDir$APKFile versionId

		### Clean up the output files
		#rm -rf $outputDir/$APKFile
		rm -rf $outputDir/*
	
		cd ../

	done


	date2=$(date +"%s")
	diff=$(($date2-$date1))
	echo "Stowaway Total Running Time $(($diff / 60)) minutes and $(($diff % 60)) seconds."  >> $logLocation
	echo "Stowaway End:" `date` >> $logLocation