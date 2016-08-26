#!/bin/sh

set -e

shopt -s nullglob

# files in current directory with '_' in their names
files=(*_*)

mkdir -p out

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
    mkdir -p ./out/$dir
    binary_name $f
    mv $f ./out/$dir/$binaryname

    # README & LICENSE
    # ignore file not exist error
    cp README* ./out/$dir/ 2>/dev/null || :
    cp LICENSE ./out/$dir/ 2>/dev/null || :

    # [[  ]]
    if [[ $dir == *"darwin"* ]] || [[ $dir == *"windows"* ]]; then
        # exclude parent folder
        cd ./out
        zip -q -r ./$dir.zip ./$dir
        cd ..
    else
        # exclude parent folder
        tar -czf ./out/$dir.tar.gz -C ./out $dir
    fi

    rm -rf ./out/$dir
done