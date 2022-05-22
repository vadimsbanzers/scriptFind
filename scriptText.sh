#! /usr/bin/env bash

# Description:
#
# Looks for files within a given directory with an extension of ".c", and removes any text between the preprocessor "#ifdef DEBUG" and "#endif"
#
# Author: Vadims Banzers
# Version: 1.0
# Date created: 11/05

#WARNING!The script does not work if either a directory name or a file name contains empty space.

directory=""  # Here you can set a directory (absolute directory) that will be searched. if empty, current directory will be used (you can check your current directory by typing "pwd" in the terminal).

Help()
{
   # Display Help
   echo "Description:"
   echo "Looks for files within a given directory with an extension of '.c', and removes any text between the preprocessor '#ifdef DEBUG' and '#endif'"
   echo
   echo "Syntax: ./scriptText"
   echo 
   echo "How to use:"
   echo  
   echo "Open the script and change the variable 'directory' to which ever directory you want to use"
   echo "Current directory will be used if the variable is left empty"

}
while getopts ":h" option; do
   case $option in
      h) # display Help
         Help
         exit;;
   esac
done

if [ -z "$directory" ]; # checks the directory variable.
then
    directory="$PWD" # if left empty, it will use the current directory by using pwd.
    echo "The current directory will be used - $directory";
else
    if [ -d "$directory" ] # if a valid directory was chosen, the script will proceed.
    then
        echo "the directory: $directory has been selected"
    else # directory is not valid (non-existent), the script gets terminated.
        echo "the directory: $directory doesn't exist"
        exit 0
    fi
fi


readarray array < <(find $directory -type f -name "*.c") #finds all files in the current directory with an extension of ".c" and saves then into an array.
arrayNum="${#array[@]}" # counts number of file names saved in the array.
full="" # empty string used for calculations
fileWithGrep=0 # empty string which will be used to count the files in the array than have been processed.


for (( i=0; i<$arrayNum; i++ )) # for loop to iterate through the array
do
    a=("${array[$i]}") # the directory to the file which is currently being proccessed.
    declare -i y=$(grep -o '#ifdef DEBUG' $a | wc -l) # calculates the amount of "#ifdef DEBUG" preprocessors found
    declare -i x=$(grep -o '#endif[[:space:]]*$' $a | wc -l) # calculates the amount of "#endif" preprocessors found
    full=$(($full+$y+$x)) # adds up the numbers of preprocessors found in files so far
    if grep -q -e '#ifdef DEBUG' -e '#endif[[:space:]]*$' $a #finds files with both preprocessors
    then
        sed -i '/^#ifdef DEBUG/,/#endif[[:space:]]*$/{/^#ifdef DEBUG/!{/#endif[[:space:]]*$/!d}}' $a #removes the text between the preprocessors (the command has been borrowed from Valentin Bajarami - https://unix.stackexchange.com/questions/88382/using-sed-to-delete-everything-between-two-words)
        fileWithGrep=$((fileWithGrep+1))
    else
        echo "Error, something went wrong"
    fi
    
done

echo "We have found $arrayNum files"
echo "$fileWithGrep files have been processed"
full2=$(($full / 2))
echo "$full2 texts between preprocessors has been deleted"
