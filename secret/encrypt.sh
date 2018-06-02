#!/bin/bash

showhelp()
{
cat << ENDHELP

usage: encrypt.sh [options]
Encrypt data used by CI/CD. Compatible with travis and appveyor

Options:
    --nuget-path=<path>
      Full path to nuget.exe

    --help
      Display this help screen
ENDHELP
}

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

nuget_path="nuget.exe"

while [ $# -ge 1 ]; do
    case "$1" in
        --nuget-path=*)
            branch="`echo ${1} | awk '{print substr($0,12)}'`" ;;
        --help)
            showhelp
            exit 0
            ;;
        *)
            echo "ERROR: Unknown argument: $1"
            showhelp
            exit 1
            ;;
    esac

    shift
done

echo "Checking required software"

if [ "$os" == "windows" ]; then
    $nuget_path
    if [ $? -ne 0 ]; then
        echo "nuget package wasn't found in PATH. Specify path to nuget.exe with --nuget-path option. See help for more info."
        exit 3
    fi
fi
