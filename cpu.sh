#!/bin/bash 

DATE=$(date +%F-%H:%M:%S)
jdk_path=/opt/edas/jdk/jdk1.8.0_65
log_path_tmp=/home/admin/javacpu
top_path=/usr/bin
RED='\E[1;31m' #红
GREEN='\E[1;32m' #绿
RES='\E[0m'
FAIL='\E[31;47m'

#判断/home/admin/javacpu是否存在
if [ ! -d "${log_path_tmp}"  ];then
	mkdir -p "${log_path_tmp}"	
	chown admin:admin -R "${log_path_tmp}"
fi

#将CPU大于90的PID和百分率输出到CPUHigh_PID.txt文件
echo `$top_path/top -bn 1 -i | grep PID -A 2| grep -w java | awk '{if ($9 > 90)print $1,$9}'` > ${log_path_tmp}/CPUHigh_PID.txt
#CPU_FIR=CPU使用率
CPU_FIR=`awk '{print $2}' ${log_path_tmp}/CPUHigh_PID.txt`
#PID_FIR=进程的PID
PID_FIR=`awk '{print $1}' ${log_path_tmp}/CPUHigh_PID.txt` 

#再次输出CPU和PID追加到指定文件，以下变量同上一致
check_pid () {
    	echo `$top_path/top -bn 1 -i| grep -w java | awk '{if ($9 > 90)print $1,$9}'` >> ${log_path_tmp}/CPUHigh_PID.txt
        CPU_AFT=`awk 'NR==2{print $2}' ${log_path_tmp}/CPUHigh_PID.txt`
        PID_AFT=`awk 'NR==2{print $1}' ${log_path_tmp}/CPUHigh_PID.txt`
        echo -e "${GREEN}At second,current pid:$PID_AFT,cpu:$CPU_AFT${RES}"
}

#查找线程TID 转换并打印堆栈信息
print_stat () {
#获取线程的TID值
        TID=`ps -mp ${PID_AFT} -o THREAD,tid | sort -rnk 2 |head -n 3 |sed -n 2p | awk '{print $8}'`
#将TID进程十六进制转换
        STAT=$(printf '%x\n' $TID)
#转换后的TID追加到CPUHigh_PID.txt文件
        echo -e "${GREEN}PID $PID_AFT TID $TID $STAT${RES}" >> ${log_path_tmp}/CPUHigh_PID.txt 
	echo -e "${GREEN}su - admin -c '$jdk_path/bin/jstack $PID_AFT | grep $STAT -A 30'${RES}" >> ${log_path_tmp}/ThreadOf_PID.txt 
#切换admin用户执行操作，打印堆存储 堆栈信息        
	su - admin -c "
	echo 'jstack info======================================================================================================' > ${log_path_tmp}/${DATE}CPU.txt
	$jdk_path/bin/jstack ${PID_AFT}| tee ${log_path_tmp}/ThreadInfos.txt | grep $STAT -A 30 >> ${log_path_tmp}/${DATE}CPU.txt
	echo 'jinfo info=======================================================================================================' >> ${log_path_tmp}/${DATE}CPU.txt
	$jdk_path/bin/jinfo -flags ${PID_AFT} >> ${log_path_tmp}/${DATE}CPU.txt
	echo 'jstat class info=================================================================================================' >> ${log_path_tmp}/${DATE}CPU.txt
	$jdk_path/bin/jstat -class ${PID_AFT} >> ${log_path_tmp}/${DATE}CPU.txt
	echo 'jstat gc info====================================================================================================' >> ${log_path_tmp}/${DATE}CPU.txt
	$jdk_path/bin/jstat -gc ${PID_AFT} >> ${log_path_tmp}/${DATE}CPU.txt
	echo 'jstat gccapacity info============================================================================================' >> ${log_path_tmp}/${DATE}CPU.txt
	$jdk_path/bin/jstat -gccapacity ${PID_AFT} >> ${log_path_tmp}/${DATE}CPU.txt
	echo 'jstat gccnew info================================================================================================' >> ${log_path_tmp}/${DATE}CPU.txt
	$jdk_path/bin/jstat -gcnew ${PID_AFT} >> ${log_path_tmp}/${DATE}CPU.txt
	echo 'jstat gccnewcapacity info========================================================================================' >> ${log_path_tmp}/${DATE}CPU.txt
	$jdk_path/bin/jstat -gcnewcapacity ${PID_AFT} >> ${log_path_tmp}/${DATE}CPU.txt
	echo 'jstat gccold info================================================================================================' >> ${log_path_tmp}/${DATE}CPU.txt
	$jdk_path/bin/jstat -gcold ${PID_AFT} >> ${log_path_tmp}/${DATE}CPU.txt
	echo 'jstat gccoldcapacity info========================================================================================' >> ${log_path_tmp}/${DATE}CPU.txt
	$jdk_path/bin/jstat -gcoldcapacity ${PID_AFT} >> ${log_path_tmp}/${DATE}CPU.txt
	echo 'jstat gcutil info================================================================================================' >> ${log_path_tmp}/${DATE}CPU.txt
	$jdk_path/bin/jstat -gcutil ${PID_AFT} >> ${log_path_tmp}/${DATE}CPU.txt"
	mv ${log_path_tmp} ${log_path_tmp}-${PID_AFT}-${TID}
}
#echo 'jmap dump info===================================================================================================' >> ${log_path_tmp}/${DATE}CPU.txt
#$jdk_path/bin/jmap -dump:live,format=b,file=${log_path_tmp}/${DATE}dump ${PID_AFT}

#判断进程PID存在
if [ -n "$PID_FIR" ];then
	echo -e "${GREEN}At $DATE,current pid:$PID_FIR,cpu:$CPU_FIR${RES}"
#如果存在则执行check_pid函数
	check_pid
#判断两次PID值是否一致
	if [ -n "$PID_AFT" -a "$PID_FIR" == "$PID_AFT" ];then
		STATE=2
		echo -e "${GREEN}set flag is true,STATE is $STATE${RES}"
#判断STATE状态成功开始执行打印堆栈操作
		if [ "$STATE" == 2 ];then
			echo -e "${GREEN}At $DATE, condition STATE $STATE is TRUE,now print details
			      please see /root/javacpu/${DATE}CPU.txt${RES}"
			print_stat
		fi
	else
		echo -e "${FAIL}At second,PID is NOT GREATER CONDITION !!!${RES}"
	fi
else
	echo -e "${FAIL}At $DATE,PID is NOT GREATER CONDITION !!!${RES}"
fi

