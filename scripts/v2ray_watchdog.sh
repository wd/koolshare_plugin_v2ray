#!/bin/sh

alias echo_date='echo 【$(TZ=UTC-8 date -R +%Y年%m月%d日\ %X)】:'

eval `dbus export v2ray`

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
    echo_date "写入配置文件"
    if [ -n "$v2ray_config" ];then
        echo_date "优先使用 JSON 配置"
        echo "$v2ray_config" | base64_decode > $v2ray_dir/config.json
    else
        echo_date "生成配置文件"
echo '{
  "log": {
    "loglevel": "none"
  },
  "inbound": {
    "port": 23456,
    "listen": "127.0.0.1",
    "protocol": "socks",
    "settings": {
      "udp": true
    }
  },
  "inboundDetour":
  [
   {
         "port": 3333,
         "listen": "0.0.0.0",
         "protocol": "dokodemo-door",
         "settings": {
             "network": "tcp,udp",
             "followRedirect": true
         }
    }
  ],
  "outbound": {
    "protocol": "vmess",
    "settings": {
      "vnext": [
        {
          "address": "V2RAY_ADDRESS",
          "port": V2RAY_PORT,
          "users": [
            {
              "id": "V2RAY_UUID",
              "alterId": V2RAY_ALTERID,
              "security": "auto"
            }
          ]
        }
      ]
    },
   "streamSettings": {
      "network": "tcp"
    }
  },
  "policy": {
    "levels": {
      "0": {"uplinkOnly": 0}
    }
  }
}' \
| sed "s/V2RAY_ADDRESS/$v2ray_address/" \
| sed "s/V2RAY_PORT/$v2ray_port/" \
| sed "s/V2RAY_UUID/$v2ray_uuid/" \
| sed "s/V2RAY_ALTERID/$v2ray_alterid/" > $v2ray_dir/config.json
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

    if [ ! -f "$koolshare_dir/ss/postscripts/P01v2ray.sh" ];then
        echo_date "ss 插件软链丢失，尝试重建"
        ln -sf $v2ray_dir/ss/postscripts/P01v2ray.sh $koolshare_dir/ss/postscripts/P01v2ray.sh
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
