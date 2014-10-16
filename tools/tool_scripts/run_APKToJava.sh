#!/bin/bash 

## Usage
## ./run_APKToJava {directory of .apk files}

## Description: Converts all apk files in a given directory to .class and .java files
### Make sure that open-jdk is installed 
### sudo apt-get install openjdk-7-jdk

## Location of directory holding all java conversion functionality
apk_Conv_dir=APK_to_JAVA

### Input location with all of the .apk files to be analyzed
APKInputDir=$1 

logLocation=logs/convert_apk.log

### Remove the log if it is there
rm -f $logLocation

## Create the log
touch $logLocation

date1=$(date +"%s") # Start Run Time

### Main directory of all the generated java output
javaOutputLocation=apkToJavaOutput
mkdir -p $javaOutputLocation

### Convert individual .apk to .class/.java files
convertAPK (){
	
	echo Working DIR: `pwd`
	echo "Begin APK To Java:" `date` " " $1 >> $logLocation
	inputFileName=$(basename $1 .apk)

	### Application Name without .apk
	appName=${1//.apk/""}

    ### Output folder name is application name without .apk
	outputFolderName=${1//.apk/""}

	JavaOutputDir=$javaOutputLocation/$outputFolderName
	dirAndAppName=$JavaOutputDir/$1

	mkdir -p $JavaOutputDir

	cp $APKInputDir/$1 $JavaOutputDir

	## Start analyzing the apk files
	java -jar $apk_Conv_dir/apktool1.5.2/apktool.jar d -f $dirAndAppName
	
	### Not sure why it creates an output file here, but delete it
	### This is a messy fix
    rm -rf $inputFileName

	## Create the dex file
	jar xvf $JavaOutputDir/$1 classes.dex

    # Move the classes.dex file to the output directory so we can unzip it
	mv classes.dex $JavaOutputDir/

    # Extract the classes.dex file
	./$apk_Conv_dir/dex2jar-0.0.9.15/dex2jar.sh $JavaOutputDir/classes.dex

	## Switching locations was the only way to have everything output in the appropriate location.
	cd $JavaOutputDir
	jar xvf classes_dex2jar.jar 
	cd ../../ 


	### Get number of classes to be analyzed
	### This will provide a rough estimate of the classes to be analyzed
	classCompareCount=`find $JavaOutputDir -type f -name '*.class' | wc -l`
	echo "Classes to convert:" $classCompareCount  `date` >> $logLocation

	count=0 ### Clear the counter

	## Now convert all of the .class files to .java
	java -jar $apk_Conv_dir/jd-cmd/jd-cli/target/jd-cli.jar $JavaOutputDir -od $JavaOutputDir

		
 	## Log the results
 	classFileCount=`find $JavaOutputDir -type f -name '*.class' | wc -l`
 	javaFileCount=`find $JavaOutputDir -type f -name '*.java' | wc -l`

	echo "	*****Output Dir: " `echo $JavaOutputDir` "Class files " `echo $classFileCount` >> $logLocation
	echo "	" `echo $appName` " Class Files Created: " $classFileCount

	echo "	*****Output Dir: " `echo $JavaOutputDir` "Java files " `echo $javaFileCount` >> $logLocation
	echo "	" `echo $appName` " Java Files Created: " $javaFileCount


}

## Remove spaces in the filenames. This will cause probems for the rest of the application.
find $APKInputDir -name '* *' | while read file;
do
	target=`echo "$file" | sed 's/ /_/g'`;
	echo "Renaming '$file' to '$target'";
	mv "$file" "$target";
done;

echo "Start Date:" `date` >> $logLocation

## Loop through all the contents of the main APK directory and convert to .class/.java files
FILES=$(find $APKInputDir -type f -name '*.apk')
for f in $FILES
do
	#echo $f
	convertAPK $(basename $f)
	#echo $(basename $f)
done


### Log end date/time
date2=$(date +"%s")
diff=$(($date2-$date1))

echo "convert_APK End:" `date` >> $logLocation
echo "Total Time $(($diff / 60)) minutes and $(($diff % 60)) seconds."  >> $logLocation
