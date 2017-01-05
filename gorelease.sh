#!/bin/sh
########################################################
#                                                      #
# This is a helper script for releasing golang project #
# Author: XuQingfeng                                   #
# Website: https://github.com/xuqingfeng               #
#                                                      #
########################################################

set -e

shopt -s nullglob

usage(){
    cat <<EOF
Usage: cd <golang project directory> && gorelease.sh [name]
EOF
    exit 0
}

if [ -z "$1" ]; then
    # use directory name
    NAME="${PWD##*/}"
else
    # use first arg
    NAME=$1
fi

# https://unix.stackexchange.com/questions/126938/why-is-setting-a-variable-before-a-command-legal-in-bash
echo "Building..."
# build darwin bin
GOOS=darwin GOARCH=386 go build -o "$NAME"_darwin_386
GOOS=darwin GOARCH=amd64 go build -o "$NAME"_darwin_amd64

# build linux bin
GOOS=linux GOARCH=386 go build -o "$NAME"_linux_386
GOOS=linux GOARCH=amd64 go build -o "$NAME"_linux_amd64
GOOS=linux GOARCH=arm go build -o "$NAME"_linux_arm
GOOS=linux GOARCH=arm64 go build -o "$NAME"_linux_arm64

# build windows bin
GOOS=windows GOARCH=386 go build -o "$NAME"_windows_386
GOOS=windows GOARCH=amd64 go build -o "$NAME"_windows_amd64


echo "Packaging..."
# files in current directory with multiple '_' in their names (avoid *_test.go)
files=(*_*_*)

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

# output usage
if [ "$1" == "-h" ]; then
    usage
fi

if [ ${#files[@]} -eq 0 ]; then
    usage
fi

for f in ${files[*]}; do

    underscore_to_dash $f
    dir="${filename%.*}"
    mkdir -p ./out/$dir
    binary_name $f
    cp $f ./out/$dir/$binaryname

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
    rm $f
done