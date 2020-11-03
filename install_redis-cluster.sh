#!/bin/bash

DIR=/usr/local
RDCF=redis.conf
RDDIR=redis-cluster
IP=127.0.0.1
NUM=`ps -ef | grep redis | grep -v grep | wc -l`


if [  -e $DIR/$RDDIR/7001/$RDCF ] ; then 

	for i in {1..6};do
		$DIR/redis/bin/redis-server $DIR/$RDDIR/700$i/$RDCF
	done

		if [ $NUM -gt 5 ]; then
			/usr/local/bin/redis-trib.rb create --replicas $IP:7001 $IP:7002 $IP:7003 $IP:7004 $IP:7005 $IP:7006
			echo -e "\033[31m ---redis--cluster----is-----OK-----!!!---------- \033[0m"
			echo -e "\033[31m ---redis--cluster--is----runing------- \033[0m"
		fi
else
	 	 mkdir -p $DIR/$RDDIR/700{1,2,3,4,5,6}
                        cp $DIR/redis/$RDCF $DIR/$RDDIR/7001
                        cp $DIR/redis/$RDCF $DIR/$RDDIR/7002
                        cp $DIR/redis/$RDCF $DIR/$RDDIR/7003
                        cp $DIR/redis/$RDCF $DIR/$RDDIR/7004
                        cp $DIR/redis/$RDCF $DIR/$RDDIR/7005
                        cp $DIR/redis/$RDCF $DIR/$RDDIR/7006
        for i in {1..6} ; do
                sed -i 's/port 6379/port '700$i'/' $DIR/$RDDIR/700$i/$RDCF
        done 
        for i in {1..6} ; do
                sed -i 's/redis_6379.pid/redis_'700$i'.pid/' $DIR/$RDDIR/700$i/$RDCF
        done 
        for i in {1..6} ; do
                sed -i 's/nodes-6379.conf/nodes-'700$i'.conf/' $DIR/$RDDIR/700$i/$RDCF
        done 
	
		for i in {1..6};do
			$DIR/redis/bin/redis-server $DIR/$RDDIR/700$i/$RDCF
		done

		if [ $NUM -gt 5 ]; then
			/usr/local/bin/redis-trib.rb create --replicas $IP:7001 $IP:7002 $IP:7003 $IP:7004 $IP:7005 $IP:7006
			echo -e "\033[31m ---redis--cluster----is-----OK-----!!!---------- \033[0m"
			echo -e "\033[31m ---redis--cluster--is----runing------- \033[0m"
		fi
	

	echo -e "\033[31m ---redis--cluster--is----down!!------- \033[0m"
   fi
