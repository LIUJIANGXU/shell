#!/bin/bash
FILE=/var/ftp/sltest/AutoUpdateManifest.xml
DFILE=/var/ftp/sltest
USER=nhis
PASSWD=yanfa@163.com
DIR=/root/client_sh/liujiangxu
CMD=/usr/bin
SUM=`date +%Y%m%d-%H%M%S`
#下载ftp补丁或者前台目录
$CMD/wget -nH -m -r -q  -o /dev/null --ftp-user=nhis --ftp-password=${PASSWD} 'ftp://10.1.131.27:10001/liujiangxu/*'
DLL=$(ls "/root/client_sh/liujiangxu/"*.dll"" 2>/dev/null | wc -l)

#删除ftp指定上传后文件
function delete {
ftp -v -n 10.1.131.27 10001 << EOF
        user $USER $PASSWD
        binary
        prompt off
        cd /liujiangxu/
        mdelete *
	quit
EOF
} > /dev/null
#> /dev/null
#循环替换补丁文件
function file {
		sum=0
		for i in `ls $DIR/`;do
			RAN=`echo $RANDOM |md5sum |cut -c 1`
			STR1=`grep $i $FILE | awk -F '"' '{print $4}'`
			STR=$STR1$RAN
			echo "原版本: `$CMD/grep $i $FILE`"
			$CMD/sed -i "/$i\"/s/version="\"$STR1\""/version="\"$STR\""/g" $FILE
	  		echo "替换后: `$CMD/grep $i $FILE`"
			$CMD/mv -f $DIR/$i $DFILE/Bin/
			sum=$(($sum+1))
			continue
		done
	        echo "补丁文件已替换，ftp文件已删除，下次记得重新放,<<------------->>总替换文件个数[$sum]个，over!" 
}
#判断dll文件个数大于0
if [ "$DLL" -gt 0 ];then
	file
	delete 
#判断是否有sltest目录
elif [ -d "$DIR"/sltest ];then
	$CMD/mv $DFILE/ /tmp/sltest$SUM && $CMD/mv $DIR/sltest/ /var/ftp/
	echo "前台目录已替换，ftp文件已删除，下次记得重新放" 
else
	echo "没有规定文件替换"
	rm -fr $DIR/*
fi
