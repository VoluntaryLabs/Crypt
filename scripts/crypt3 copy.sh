#!/bin/sh

usage () {
	echo "usages: "
	echo "	crypt3 -decrypt -delete key path"
	echo "	crypt3 -decrypt -keep   key path"
	echo "	crypt3 -encrypt -delete key path"
	echo "	crypt3 -encrypt -keep   key path"
	exit 1
}

command=${1}
shred=${2}
key=${3}
filePath=${4}

keyHash=`echo "${key}" | openssl dgst -sha1 | awk '{ print substr($1, 0, 4) }'`

#echo $0 $1 $2 $3 $4
#echo "command   = '${command}'"
#echo "shred     = '${shred}'"
#echo "key       = '${key}'"
#echo "filePath  = '${filePath}'"
#echo "keyHash  = '${keyHash}'"

if [ $command = "-encrypt" ]; then
		
	folder=`dirname "${filePath}"`
	name=`basename "${filePath}"`

	#echo "encrypting '${filePath}'"
	#echo "folder   = '${folder}'"
	#echo "name   = '${name}'"
	
	tar -cf - -C "${folder}" "${name}"  | gzip --fast | openssl enc -bf-ecb -salt -k "${key}" -out "${filePath}.tgz.bf-ecb.${keyHash}.crypt3"
	
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
	
	if [ $filePathHash = $keyHash ]; then
		echo ""
	else
		echo "Error: hash of input key does not match the key hash '${filePathHash}' contained in the file name"
		exit 0
	fi

	#echo "decrypting '${filePath}'"
	
	if [ $fileType = "tgz" ]; then
		folder=`dirname "$filePath"`
		openssl enc -d -bf-ecb -salt -k "${key}" -in "${filePath}" | gunzip | tar -x -C "$folder"
	else
		echo "unrecognized compression suffix"
		exit 1
	fi
	
	if [ $shred = "-delete" ]; then
		srm -f -s "${filePath}"
	fi
else
	usage
fi
