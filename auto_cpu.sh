#!/usr/bin/env bash
#*/3 * * * * sh /root/javacpu/cpu.sh > /root/javacpu/cpu.log 2>&1

DATE=$(date +%F-%H:%M:%S)
jdk_path=/opt/edas/jdk/jdk1.8.0_65
log_path_tmp=/home/admin/javacpu
log_path=/root/javacpu
cron_path=/var/spool/cron/root
top_path=/usr/bin
if [ ! -d "$log_path_tmp"  ];then
	mkdir -p "$log_path_tmp"	
	chown admin:admin -R "$log_path_tmp"
fi
#将CPU大于90的PID和百分率输出到CPUHigh_PID.txt文件
echo `$top_path/top -bn 1 -i | grep PID -A 2| grep -w java | awk '{if ($9 > 90)print $1,$9}'` > $log_path/CPUHigh_PID.txt
#CPU_FIR=CPU使用率
CPU_FIR=$(awk '{print $2}' $log_path/CPUHigh_PID.txt)
#PID_FIR=进程的PID
PID_FIR=$(awk '{print $1}' $log_path/CPUHigh_PID.txt)

#再次输出CPU和PID追加到指定文件，以下变量同上一致
check_pid () {
    	echo `$top_path/top -bn 1 -i| grep -w java | awk '{if ($9 > 90)print $1,$9}'` >> $log_path/CPUHigh_PID.txt
        CPU_AFT=$(awk 'NR==2{print $2}' $log_path/CPUHigh_PID.txt)
        PID_AFT=$(awk 'NR==2{print $1}' $log_path/CPUHigh_PID.txt)
        echo "At second,current pid:$PID_AFT,cpu:$CPU_AFT"
}

#查找线程TID 转换并打印堆栈信息
print_stat () {
#获取线程的TID值
        TID=$(ps -mp ${PID_AFT} -o THREAD,tid，time | sort -rnk 2 |head -n 3 |sed -n 2p | awk '{print $8}')
#将TID进程十六进制转换 
		STAT=$(printf '%x\n' $TID)
#转换后的TID追加到CPUHigh_PID.txt文件
        echo "PID $PID_AFT TID $TID $STAT" >> $log_path/CPUHigh_PID.txt 
		echo "su - admin -c '$jdk_path/bin/jstack $PID_AFT | grep $STAT -A 30'" >> $log_path/ThreadOf_PID.txt 
#切换admin用户执行操作，打印堆存储、堆栈信息        
	su - admin -c "
	echo 'jstack info===================================================================================================' > $log_path_tmp/${DATE}CPU.txt
	$jdk_path/bin/jstack ${PID_AFT}| tee $log_path_tmp/ThreadInfos.txt | grep $STAT -A 30 >> $log_path_tmp/${DATE}CPU.txt
	echo 'jinfo info====================================================================================================' >> $log_path_tmp/${DATE}CPU.txt
	$jdk_path/bin/jinfo -flags ${PID_AFT} >> $log_path_tmp/${DATE}CPU.txt
	echo 'jstat class info==============================================================================================' >> $log_path_tmp/${DATE}CPU.txt
	$jdk_path/bin/jstat -class ${PID_AFT} >> $log_path_tmp/${DATE}CPU.txt
	echo 'jstat gc info=================================================================================================' >> $log_path_tmp/${DATE}CPU.txt
	$jdk_path/bin/jstat -gc ${PID_AFT} >> $log_path_tmp/${DATE}CPU.txt
	echo 'jstat gccapacity info=========================================================================================' >> $log_path_tmp/${DATE}CPU.txt
	$jdk_path/bin/jstat -gccapacity ${PID_AFT} >> $log_path_tmp/${DATE}CPU.txt
	echo 'jstat gccnew info=============================================================================================' >> $log_path_tmp/${DATE}CPU.txt
	$jdk_path/bin/jstat -gcnew ${PID_AFT} >> $log_path_tmp/${DATE}CPU.txt
	echo 'jstat gccnewcapacity info=====================================================================================' >> $log_path_tmp/${DATE}CPU.txt
	$jdk_path/bin/jstat -gcnewcapacity ${PID_AFT} >> $log_path_tmp/${DATE}CPU.txt
	echo 'jstat gccold info=============================================================================================' >> $log_path_tmp/${DATE}CPU.txt
	$jdk_path/bin/jstat -gcold ${PID_AFT} >> $log_path_tmp/${DATE}CPU.txt
	echo 'jstat gccoldcapacity info=====================================================================================' >> $log_path_tmp/${DATE}CPU.txt
	$jdk_path/bin/jstat -gcoldcapacity ${PID_AFT} >> $log_path_tmp/${DATE}CPU.txt
	echo 'jstat gcutil info=============================================================================================' >> $log_path_tmp/${DATE}CPU.txt
	$jdk_path/bin/jstat -gcutil ${PID_AFT} >> $log_path_tmp/${DATE}CPU.txt"
        mv $log_path_tmp/* $log_path/
}
#echo 'jmap dump info================================================================================================' >> $log_path_tmp/${DATE}CPU.txt
#$jdk_path/bin/jmap -dump:live,format=b,file=$log_path_tmp/${DATE}dump ${PID_AFT}"


#判断PID_FIR变量是否存在
if [ -n "$PID_FIR" ];then
	echo "At $DATE,current pid:$PID_FIR,cpu:$CPU_FIR"
	sleep 1s
	check_pid
#判断PID_FIR和PID_AFT变量是否一致
	if [ -n "$PID_AFT" -a "$PID_FIR" == "$PID_AFT" ];then
		STATE=2
		if [ "$STATE" == 2 ];then
			cat $cron_path > $log_path/contab.bak
#将任务计划中cpu.sh文件前面加注释
			sed -i '/cpu.sh/ s/^/#/g' "$cron_path"
			echo `grep -in cpu.sh "$cron_path"`
			echo "At $DATE, condition STATE $STATE is TRUE,now print details
			      please see /root/javacpu/${DATE}CPU.txt"
#执行打印函数
			print_stat
#睡眠2小时
			sleep 2H
			echo "after 2hours crontab is start"
#2小时后将cron中取消注释
			sed -i '/cpu.sh/ s/^#//g' "$cron_path"
			echo `grep -in cpu.sh "$cron_path"`
		fi
	else
		echo "At second,PID is NOT GREATER CONDITION"
	fi
else
	echo "At $DATE,PID is NOT GREATER CONDITION"
fi
