#!/bin/sh

# shadowsocks script for AM380 merlin firmware
# by sadog (sadoneli@gmail.com) from koolshare.cn

eval `dbus export ss`
alias echo_date='echo 【$(TZ=UTC-8 date -R +%Y年%m月%d日\ %X)】:'

check_status(){
    echo_date "v2ray 检测"

    echo_date "-----------------------------"
    echo_date "v2ray 目录"
    ls -alh /jffs/v2ray

    echo_date "v2ray 版本"
    /jffs/v2ray/v2ray --version

    echo_date "验证 v2ray 配置文件"
    cat /jffs/v2ray/config.json | /jffs/v2ray/v2ctl config >/dev/null

    echo_date "v2ray 进程"
    ps | grep v2ray

    echo_date "v2ray 监听"
    /koolshare/bin/netstat -nlp | grep 'v2ray'

    [ -f /tmp/v2ray.log ] && echo_date "v2ray 重启情况" && tail -5 /tmp/v2ray.log

    echo_date "v2ray watchdog"
    cat /var/spool/cron/crontabs/*|grep v2raywatchdog

    echo_date "dns 监听"
    ps | grep 23456
}

if [ "$ss_v2ray_enable" == "1" ];then
	check_status > /tmp/v2ray_status.log 2>&1
else
	echo 插件尚未启用！
fi
echo "O(∩_∩)O~" >> /tmp/v2ray_status.log
echo "XU6J03M6" >> /tmp/v2ray_status.log
