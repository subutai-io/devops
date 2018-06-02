#!/bin/bash

os=`uname`
wos=${os:0:5}

if [ "$os" == "Darwin" ]; then
    echo "Encrypting on Darwin"
elif [ "$os" == "Linux" ]; then
    echo "Encyrpting on Linux"
elif [ "$wos" == "MINGW" ]; then
    echo "Encyrpting on Windows"
else
    echo "Unknown operating system: ${os} ${wos}"
    exit 2
fi
