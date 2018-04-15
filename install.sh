#!/bin/sh

alias echo_date='echo 【$(TZ=UTC-8 date -R +%Y年%m月%d日\ %X)】:'

v2ray_dir='/jffs/v2ray/'
koolshare_dir="/koolshare"
CUR_VERSION="0.3"

check_ss(){
    ss_version=`dbus get ss_basic_version_local`
    if [ -n "$ss_version" ];then
        ss_comp=`versioncmp 3.8.5 $ss_version`
        echo_date "检测到SS版本号为 $ss_version"
        echo_date "此离线包只支持 3.8.6 及以上版本 ss 插件($ss_comp)"
        return "$ss_comp"
    fi
    return 0
}

remove_old_config(){
    sed -i "/grep -q 'v2ray_watchdog.sh'/d" /jffs/scripts/nat-start
    sed -i "/grep -q 'v2ray_watchdog.sh'/d" /jffs/scripts/wan-start
    sed -i '/v2ray_watchdog.sh$/d' /var/spool/cron/crontabs/*
}

main(){
    mkdir -p $v2ray_dir
    if [ ! -d "$koolshare_dir/ss" ];then
        echo_date "需要先安装 koolshare ss"
        exit 99
    fi

    check_ss
    if [ "$?" -eq 0 ];then
        echo_date "SS 版本要求不够，退出安装"
        exit 99
    fi

    echo_date "移除旧的 nat-start/wan-start/crontab 配置"
    remove_old_config

    cd /tmp/v2ray
    echo_date "复制界面文件"
    cp Main_Ss_Content.asp $koolshare_dir/webs/Main_Ss_Content.asp
    echo_date "复制启动脚本"
    cp P01v2ray.sh $koolshare_dir/ss/postscripts/
    echo_date "复制 watchdog"
    cp v2ray_watchdog.sh $v2ray_dir
}
main
dbus set softcenter_module_v2ray_install=1
dbus set softcenter_module_v2ray_version="$CUR_VERSION"
dbus set softcenter_module_v2ray_title="科学上网v2ray插件"
dbus set softcenter_module_v2ray_description="科学上网v2ray插件"
dbus set softcenter_module_v2ray_home_url=Main_Ss_Content.asp
