#/bin/sh
docker run -d -p 8080:80 -p 2202:22 -t dockerfile/xpressengine /usr/sbin/runsvdir-start
