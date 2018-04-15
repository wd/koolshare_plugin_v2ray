#!/bin/sh

alias echo_date='echo 【$(TZ=UTC-8 date -R +%Y年%m月%d日\ %X)】:'

start_v2ray(){
	echo_date "启动v2ray"
    /jffs/v2ray/v2ray_watchdog.sh start
}

stop_v2ray(){
	echo_date "停止v2ray"
    /jffs/v2ray/v2ray_watchdog.sh stop
}

case $1 in
start)
	start_v2ray
	;;
stop)
	stop_v2ray
	;;
esac
