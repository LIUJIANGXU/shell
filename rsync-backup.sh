#!/bin/bash
SRC=/data/
DES=data
rsync_passwd_fil=/etc/rsyncd.passwd
IP1=192.168.108.131
IP2=192.168.108.132
USER=root

cd $SRC
/usr/local/bin/inotifywait -mrq --format '%Xe %w%f' -e modify,create,delete,attrib,close_write,move ./ | while read file 
	do
	INO_EVENT=`echo $file | awk '{print $1}'` 
	INO_FILE=`echo $file | awk '{print $2}'`
	echo "-----------------------------$(date)--------------------------------------------"
	echo $file

 if [[ $INO_EVENT =~ "CREATE" ]] || [[ $INO_EVENT =~ "MODIFY" ]] || [[ $INO_EVENT =~ "CLOSE_WRITE" ]] || [[ $INO_EVENT =~ "MOVED_YO" ]];then
	echo 'CREATE or MODIFY or CLOSE_WRITE or MOVED_TO'
	rsync -avzcR --password-file=${rsync_passwd_file} $(dirname ${INO_FILE}) ${USER}@${IP1}::${DES} &&
	rsync -avzcR --password-file=${rsync_passwd_file} $(dirname ${INO_FILE}) ${USER}@${IP2}::${DES}
 fi
 
 if [[ $INO_EVENT =~ "DELETE" ]] || [[ $INO_EVENT =~ "MOVED_FROM" ]];then
	echo 'DELETE or MOVED_FROM'
	rsync -avzR --delete --password-file=${rsync_passwd_file} $(dirname ${INO_FILE}) ${USER}@${IP1}::${DES} &&
	rsync -avzR --delete --password-file=${rsync_passwd_file} $(dirname ${INO_FILE}) ${USER}@${IP2}::${DES} 
 fi

 if [[ $INO_EVENT =~ "ATTRIB" ]];then
	echo 'ATTRIB'
	if [ ! -d "$INO_FILE" ];then
		rsync -avzcR  --password-file=${rsync_passwd_file} $(dirname ${INO_FILE}) ${USER}@${IP1}::${DES} &&
		rsync -avzcR  --password-file=${rsync_passwd_file} $(dirname ${INO_FILE}) ${USER}@${IP2}::${DES} 
	fi
fi
done
	
