#£¡/bin/bash

export JAVA_HOME=/usr/local/jdk1.8.0_221/
export JAVA_BIN=$JAVA_HOME/bin
export JRE_HOME=$JAVA_HOME/jre
export JAVA_LIB=$JAVA_HOME/lib
export CLASSPATH=.:$JAVA_LIB/tools.jar:$JAVA_LIB/dt.jar
export PATH=$JAVA_BIN:$PATH

/usr/local/apache-zookeeper-3.5.5-bin/bin/zkServer.sh start &
/usr/local/redis/bin/redis-server /usr/local/redis/conf/redis.conf

/usr/local/apache-tomcat-8.5.45/bin/startup.sh &

exit

# echo "nohup /root/delayfsboot.sh &" >> /etc/rc.local