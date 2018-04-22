#!/bin/sh

alias echo_date='echo 【$(TZ=UTC-8 date -R +%Y年%m月%d日\ %X)】:'
koolshare_dir='/koolshare'

start_v2ray(){
	echo_date "启动v2ray"
    $koolshare_dir/scripts/v2ray_watchdog.sh start
}

stop_v2ray(){
	echo_date "停止v2ray"
    $koolshare_dir/scripts/v2ray_watchdog.sh stop
}

case $1 in
start)
	start_v2ray
	;;
stop)
	stop_v2ray
	;;
esac
