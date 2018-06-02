#!/bin/bash

oos=`uname`
wos=${a:0:5}
os=

if [ "$oos" == "Darwin" ]; then
    echo "Encrypting on Darwin"
    os="darwin"
elif [ "$oos" == "Linux" ]; then
    echo "Encyrpting on Linux"
    os="linux"
elif [ "$wos" == "MINGW" ]; then
    echo "Encyrpting on Windows"
    os="windows"
else
    echo "Unknown operating system: ${oos}"
    exit 2
fi

echo "Checking required software"

if [ "$os" == "windows" ]; then
    nuget.exe
    if [ $? -ne 0 ]; then
        echo "nuget package wasn't found in path. Specify path to nuget.exe with --nuget-path option. See help for more info."
        exit 3
    fi
fi