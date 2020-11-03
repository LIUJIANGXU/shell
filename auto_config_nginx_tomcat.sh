#!/bin/bash
# 2019򲀧0�23:13:15
#auto config tomcat nginx
#by author jiangxu
###############################
#install and config JDK

VHOST="$1"
if [ ! -f /usr/java/jdk1.7.0_75 ];then
	tar zxf jdk1.7.0_75.tar.gz
	mkdir -p /usr/java/
	mv jdk1.7.0_75 /usr/java/
cat>>/etc/profile<<EOF
export JAVA_HOME=/usr/java/jdk1.7.0_75
CLASSPATH=\$CLASSPATH:\$JAVA_HOME/lib:\$JAVA_HOME/jre/lib
export PATH=\$PATH:\$JAVA_HOME/bin:\$JAVA_HOME/jre/bin:\$HOMR/bin
EOF
	source /etc/profile
	sleep 3
fi

#install and config nginx

if [ ! -f /usr/local/nginx/sbin/nginx ];then
	yum install gcc gcc-c++ pcre pcre-devel zlib zlib-devel -y
	yum install make wget tar openssl openssl-devel perl perl-devel -y
	tar zxf nginx-1.12.2.tar.gz
	cd  nginx-1.12.2
	./configure 
	make && make install
	/usr/local/nginx/sbin/nginx
	netstat -tunlp | grep 80
	ps -ef |grep nginx
fi

#config nginx nginx.conf
	cd /usr/local/nginx/conf/
	grep "include  test" /nginx.conf >>/dev/null 2>&1
if [ $? -ne 0 ];then
	grep -vE "#|^$" nginx.conf.default>nginx.conf.swp
	sed -i '/server/,$d' nginx.conf.swp
	echo -e "include  test/*; \n} ">> nginx.conf.swp
	\mv nginx.conf.swp nginx.conf
	mkdir -p test
fi

#config tomcat server

cp /root/jiangxu /usr/local/nginx/conf/test/$VHOST
sed -i "s/xxx/$VHOST/g" /usr/local/nginx/conf/test/$VHOST
mkdir -p /data/webapps/$VHOST/
cp -a /root/apache-tomcat-7.0.94 /usr/local/tomcat_$VHOST
cp -a /usr/local/tomcat_$VHOST/webapps/ROOT/* /data/webapps/$VHOST/
cp -r /usr/local/tomcat_$VHOST/webapps/* /data/webapps/$VHOST/
rm -fr /data/webapps/$VHOST/ROOT/
/usr/local/tomcat_$VHOST/bin/startup.sh
/usr/local/nginx/sbin/nginx -s reload 

