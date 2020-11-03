#!/bin/bash
DIR1="/root/script/wardir/pscacc"
DIR2="/root/script/wardir/psccard"
DIR3="/root/script/wardir/pscpayment"
DIR4="/root/script/wardir/pscsccp"
DIR5="/root/script/wardir/psc-acc-s"
DIR6="/root/script/wardir/psc-card-s"
DIR7="/root/script/wardir/psc-payment-s"
DIR8="/root/script/wardir/pscsccp-s"

#修改war包配置文件
function change {
	mv /root/$1.war $2/ && cd $2/ 
if [ -f $1.war ];then
	jar -xf $1.war && find ./* -name "$1.war" | xargs rm -fr 
	\cp /root/script/config/$1/* $2/WEB-INF/classes/props/ 
	[ $? -eq 0 ] && jar -cfM0 $1.war ./* && mv ./$1.war /root/ && rm -fr $2/* && cd /root
fi
}

#删除原包
function delete {
	rm -fr /root/${1}.war
}
#上传war包到指定机器
function copy {
	scp /root/${1}.war root@192.168.108.131:/root/
}

#循环判断指定war包替换
if [ -f "/root/psc-acc-s.war" -o -f "/root/pscacc.war" -o -f "/root/psc-card-s.war" -o -f "/root/psccard.war" -o -f "/root/psc-payment-s.war" -o -f "/root/pscpayment.war" -o -f "/root/pscsccp-s.war" -o -f "/root/pscsccp.war" ];then
	for i in /root/*.war;do
	  WAR=`basename $i`
		case $WAR in
		pscacc.war)
		change pscacc $DIR1
		;;
		psccard.war)
		change psccard $DIR2
		;;
		pscpayment.war)
		change pscpayment $DIR3
		;;
		pscsccp.war)
		change pscsccp $DIR4
		;;
		psc-acc-s.war)
		change psc-acc-s $DIR5
		copy psc-acc-s
		delete psc-acc-s
	        ;;
	        psc-card-s.war)
	        change psc-card-s $DIR6
		copy psc-card-s
		delete psc-card-s
	        ;;
	        psc-payment-s.war)
	        change psc-payment-s $DIR7
		copy psc-payment-s
		delete psc-payment-s
	        ;;
	        pscsccp-s.war)
	        change pscsccp-s $DIR8
		copy pscsccp-s
		delete pscsccp-s
		;;
	  esac
done

else
	exit 404
fi
