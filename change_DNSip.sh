#!/bin/bash
#SFILE=/var/named/chroot/var/named/ydhl.zone
SFILE=/root/ydhl.zone
#DFILE=/var/named/chroot/var/named/bb.txt
DFILE=/root/bb.txt
RED='\E[1;31m'
GREEN='\E[1;32m'
RES='\E[0m'
FILE=`awk '{print $1}' /root/bb.txt`
#每次备份源文件
cp ${SFILE} ${SFILE}.back
while :;do
   read -p "请输入需要更换域名：" yuming
	STR=`grep "^${yuming}" $SFILE|awk '{print $1}'`
#判断输入和文件中字段是否一致
	if [[ ${yuming} = ${STR} ]];then	
		for i in $FILE;do
			#判断输入字符能否匹配
			if [ $yuming = $i ];then
				#获取源文件ip和目标ip
				SIP=`grep "^${yuming}" ${SFILE}| awk '{print $3}'`
				DIP=`grep "^${yuming}" ${DFILE}| awk '{print $2}'`
				#相互替换sip和dip
				sed -i "s/${DIP}/${SIP}/g" ${DFILE}
				sed -i "s/${SIP}/${DIP}/g" ${SFILE}
				echo -e "${GREEN}已将${yuming}的ip修改为:[${DIP}]${RES}"
				continue
			fi
    		done 
	elif [[ ${yuming} != ${STR} && $yuming = 'quit' ]];then
		echo -e "${GREEN}修改完成！\nDNS服务正在重读配置文件....${RES}"
		#修改完成重读dns然后退出
#		/usr/sbin/rndc reload
		exit 34
	else
		echo -e "${RED}没有找到需要修改的域名:[$yuming]!!${RES}"
	fi
done
