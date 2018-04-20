#!/bin/bash

# Universal script for CDN file upload
# How to use: `upload.sh <BRANCH> <PATH_TO_FILE>
# This script will specifiled file to CDN. Branch can be: HEAD, master or dev
# During the process - previous file will be removed from CDN
# Script expects to GPG key of email specified below to be in the 
# system

branch=$1
file=$2
user="devops"
email="devops@subutai.io"
gpg_cmd="gpg"
curl_cmd="curl"
os=`uname -s`

if [ -z "$branch" ]; then
    echo "Branch wasn't specified"
    exit 11
fi

if [ "$branch" != "master" ] && [ "$branch" != "dev" ] && [ "$branch" != "HEAD" ]; then
    echo "Branch ${branch} unsupported"
    exit 12
fi

if [ -z "$file" ]; then
    echo "File not specified"
    exit 13
fi

if [ ! -e "$file" ]; then
    echo "File ${file} doesn't exists"
    exit 14
fi

# this function will fill `id` variable which contains ID of file with the same name on CDN. This id will be used later to remove previous file
extract_id()
{
    if [ "$os" == "darwin" ]; then
        id_src=$(echo $json | grep -Po '"id":".*?[^\\]"')
        id=${id_src:6:36}
    else
        id_src=$(echo $json | grep -Po '"id":".*?[^\\]"')
        id=${id_src:6:36}
    fi
}

exitonfail()
{
    if [ $? -ne 0 ]; then
        exit $1
    fi
}

urlbase=""
if [ "$branch" == "master" ] || [ "$branch" == "dev" ]; then
    urlbase=$branch
fi
url=https://eu0.${urlbase}cdn.subutai.io:8338/kurjun/rest

filename=`basename $file`
id=""
# Getting ID of previous file
echo "Retrieving ID of $filename"
json=`curl -k -s -X GET $url/raw/info?name=$filename`
if [ "$json" != "Not found" ]; then
    extract_id
    if [ "$id" != "" ]; then
        echo "${filename} has ID: ${id}"
    fi
fi

# Signing auth key
echo "Signing auth key"
rm -f /tmp/filetosign*
gpg_key=$($gpg_cmd --armor --export $email)
curl -k -s "$url/auth/token?user=$user" -o /tmp/filetosign
exitonfail "Failed to acquire auth key"
$gpg_cmd --armor -u $email --clearsign /tmp/filetosign

# Acquiring token
echo "Getting auth token"
token=$(curl -k -s -Fmessage="`cat /tmp/filetosign.asc`" -Fuser=$user "$url/auth/token")

# Uploading file
echo "Uploading"
curl -k -H "token: $token" -Ffile=@$file "$url/raw/upload"

if [ ! -z "$id" ] && [ $? -eq 0 ]; then
    curl -k -s -X DELETE "$url/raw/delete?id=$id&token=$token"
    exitonfail
fi
