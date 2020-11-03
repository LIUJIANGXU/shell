#!/bin/bash

if [ id nginx ]; then
	exit
else
	yum -y install gcc gcc-c++ automake pcre pcre-devel zlip zlib-devel openssl openssl-devel
	useradd -s /sbin/nologin nginx
 	tar zxf nginx-1.16.0.tar.gz
	mv nginx-1.16.0 /usr/local/nginx
	cd /usr/local/nginx
	./configure --with-http_ssl_module  --with-http_stub_status_module --user=nginx 
	make && make install 
	echo -e "\033[31m install nginx OK \033[0m"
fi
