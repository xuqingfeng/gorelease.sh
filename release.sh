#!/bin/sh

set -e

shopt -s nullglob

files=(*_*)

mkdir -p dist

binaryname=""
binary_name(){

    if [[ $1 == *"windows"* ]]; then
        binaryname=`echo $1 | cut -d'_' -f1`
        binaryname="$binaryname.exe"
    else
        binaryname=`echo $1 | cut -d'_' -f1`
    fi
}

filename=""
underscore_to_dash(){

    filename=`echo $1 | tr '_' '-'`
}

for f in ${files[*]}; do

    underscore_to_dash $f
    dir="${filename%.*}"
    #echo $dir
    mkdir -p ./dist/$dir
    binary_name $f
    mv $f ./dist/$dir/$binaryname;

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