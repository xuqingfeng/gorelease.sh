#!/bin/sh

set -e

shopt -s nullglob

files=(*_*)

#
mkdir -p dist

# TODO: 16/8/23
binary_name(){

    return $1
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
    # TODO: binary_name
    mv $f ./dist/$dir/$f;

    # [[  ]]
    if [[ $dir == *"darwin"* ]] || [[ $dir == *"windows"* ]]; then
        zip -r ./dist/$dir.zip ./dist/$dir
    else
        tar -czf ./dist/$dir.tar.gz ./dist/$dir
    fi
done