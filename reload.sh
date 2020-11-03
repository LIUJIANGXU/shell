#!/bin/bash

FATE=$(date +%F-%H:%M)
DIR=/usr/local/psc-c/webapps
BACK=/root/beifen
#创建备份目录
if [ -d $BACK/${FATE} ];then
	status=2
else
	mkdir -p $BACK/$FATE
fi
#执行备份操作
function pscc {
if [ -f /root/${1}.war ];then
        mv $DIR/${1}.war $BACK/$FATE && rm -fr $DIR/$1
        mv /root/$1.war $DIR/
 fi
}
#循环替换war包
if [ -f "/root/pscacc.war" -o -f "/root/psccard.war" -o -f "/root/pscpayment.war" -o -f "/root/pscsccp.war" ];then
	for i in /root/*.war;do
        WAR=`basename $i`
        case $WAR in
        pscacc.war)
        pscc pscacc
        ;;
        psccard.war)
        pscc psccard
        ;;
        pscpayment.war)
        pscc pscpayment
        ;;
	pscsccp.war)
	pscc pscsccp
	;;
        esac
done
fi

