#!/bin/sh

set -e

shopt -s nullglob

# files in current directory with '_' in their names
files=(*_*)

mkdir -p dist

# get binary name
binaryname=""
binary_name(){

    # add '.exe' to windows binary
    if [[ $1 == *"windows"* ]]; then
        binaryname=`echo $1 | cut -d'_' -f1`
        binaryname="$binaryname.exe"
    else
        binaryname=`echo $1 | cut -d'_' -f1`
    fi
}

# '_' -> '-'
filename=""
underscore_to_dash(){

    filename=`echo $1 | tr '_' '-'`
}

for f in ${files[*]}; do

    underscore_to_dash $f
    dir="${filename%.*}"
    mkdir -p ./dist/$dir
    binary_name $f
    mv $f ./dist/$dir/$binaryname

    # README & LICENSE
    # ignore file not exist error
    cp README* ./dist/$dir/ 2>/dev/null || :
    cp LICENSE ./dist/$dir/ 2>/dev/null || :

    # [[  ]]
    if [[ $dir == *"darwin"* ]] || [[ $dir == *"windows"* ]]; then
        # exclude parent folder
        cd ./dist
        zip -q -r ./$dir.zip ./$dir
        cd ..
    else
        # exclude parent folder
        tar -czf ./dist/$dir.tar.gz -C ./dist $dir
    fi

    rm -rf ./dist/$dir
done