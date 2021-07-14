#!/bin/sh
# Copyright 2006 Steve Dekorte, all rights reserved

usage () {
    echo "Usage: "
    echo "    $0 -decrypt -delete key path"
    echo "    $0 -decrypt -keep   key path"
    echo "    $0 -encrypt -delete key path"
    echo "    $0 -encrypt -keep   key path"
    exit 1
}

if [[ $# != 5 && $# != 6 ]]; then
    usage
fi

opensslexe=${1}
command=${2}
shred=${3}
key=${4}
filePath=${5}
skipChecks=${6}
cipher="aes-256-cbc"

keyHash=`echo "${key}" | $opensslexe dgst -sha1 | awk '{ print substr($1, 0, 4) }'`

if [ $command = "-encrypt" ]; then
        
    folder=`dirname "${filePath}"`
    name=`basename "${filePath}"`

    #echo "encrypting '${filePath}'"
    #echo "folder   = '${folder}'"
    #echo "name   = '${name}'"
    
    tar --posix -cf - -C "${folder}" "${name}"  | gzip --fast | $opensslexe enc -${cipher} -salt -k "${key}" -out "${filePath}.tgz.${cipher}.${keyHash}.crypt3"
    
    if [ $shred = "-delete" ]; then
        #echo "deleting ${filePath}"
        srm -f -r -s "${filePath}"
    fi    
    
elif [ $command = "-decrypt" ]; then

    filename=`basename "${filePath}"`
    filePathHash=`echo "${filename}" | awk 'BEGIN { FS = "." } { print $(NF - 1) }'`
    fileType=`basename "${filePath}" | awk 'BEGIN { FS = "." } { print $(NF - 3) }'`

    
    outfilePath=`echo "${filePath}" | awk 'BEGIN { FS = "." } {
        result = $1
        for (i = 2; i <= NF - 4; i++)
            result = result "." $(i)
        print result
        }'`

    #echo "filename = ${filename}"
    #echo "filePathHash = ${filePathHash}"
    #echo "fileType = ${fileType}"
    #echo "outfilePath = $outfilePath"
    
    if [ $shred = "-testkey" ]; then
        if [ ${filePathHash} = ${keyHash} ]; then
            exit 1
        else 
            echo "invalid password hash ${filePathHash} != ${keyHash}"
            exit 0
        fi
    fi
    
    if [ $skipChecks == ""]; then
        
        if [ $filePathHash = $keyHash ]; then
            echo ""
        else
            echo "Error: hash of input key does not match the key hash '${filePathHash}' contained in the file name"
            exit 0
        fi

        #echo "decrypting '${filePath}'"

        if [ $fileType = "tgz" ]; then
            folder=`dirname "$filePath"`
            $opensslexe enc -d -${cipher} -salt -k "${key}" -in "${filePath}" | gunzip | tar -x -C "$folder"
        else
            echo "unrecognized compression suffix"
            exit 1
        fi
        
    else

        folder=`dirname "$filePath"`
        echo "raw decrypting "
        $opensslexe enc -d -${cipher} -salt -k "${key}" -in "${filePath}" | gunzip | tar -x -C "$folder"        
        echo "raw decrypting done"
        echo "$?"
    fi

    if [ "$?" -ne "0" ]; then
        echo "error decrypting - possibly due to corrupt input file or incorrect password"
        exit 2
    fi
    
    if [ $shred = "-delete" ]; then
        srm -f -s "${filePath}"
    fi
    
    echo "exit 0"
    
    exit 0
else
    usage
fi
