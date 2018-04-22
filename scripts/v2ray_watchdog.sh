#!/bin/sh

alias echo_date='echo 【$(TZ=UTC-8 date -R +%Y年%m月%d日\ %X)】:'

v2ray_enable=`dbus get v2ray_enable`
v2ray_config=`dbus get v2ray_config`
v2ray_dir='/jffs/v2ray'
koolshare_dir='/koolshare'
v2ray_bin="$v2ray_dir/v2ray"

is_v2ray_alive() {
    v2ray_count=`ps -w |grep "$v2ray_bin"|grep -v grep|grep -v watchdog|wc -l`
    if [ "$v2ray_count" -eq 1 ];then
        return 0  # work ok
    else
        return 1
    fi
}

write_config(){
    if [ -n "$v2ray_config" ];then
        echo_date "写入配置文件"
        echo "$v2ray_config" | base64_decode > $v2ray_dir/config.json
    fi
}

start_v2ray(){
    if [ "$v2ray_enable" == 1 ];then
        echo_date "执行启动v2ray"
        write_config
        stop_ss
        $v2ray_bin &
        cru a 'v2raywatchdog' "*/1 * * * * /bin/sh $koolshare_dir/scripts/v2ray_watchdog.sh"
        echo $$ > /tmp/v2ray.pid
    else
        echo_date "v2ray 开关关闭中，不执行启动"
    fi
}

stop_v2ray(){
    echo_date "执行停止v2ray"
    killall v2ray >/dev/null 2>&1
    sed -i '/v2raywatchdog/d' /var/spool/cron/crontabs/*
}

stop_ss() {
    killall ss-local >/dev/null 2>&1
    killall ss-redir >/dev/null 2>&1
    killall ssr-local >/dev/null 2>&1
    killall ssr-redir >/dev/null 2>&1
}

restart_v2ray(){
    stop_v2ray
    sleep 1
    start_v2ray
}

run_watchdog(){
    is_v2ray_alive
    if [ "$?" -ne 0 ];then
        echo_date "v2ray 进程已死，尝试启动"
        restart_v2ray
        echo_date "启动完成"
        echo "v2ray restart at "$(date) >> /tmp/v2ray.log
    fi
}

case $1 in
start)
    start_v2ray
    ;;
stop)
    stop_v2ray
    ;;
restart)
    restart_v2ray
    ;;
*)
    run_watchdog
    ;;
esac
