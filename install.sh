#!/bin/sh

alias echo_date='echo 【$(TZ=UTC-8 date -R +%Y年%m月%d日\ %X)】:'

v2ray_dir='/jffs/v2ray/'
koolshare_dir="/koolshare"

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
    echo_date "复制文件到 koolshare 目录"
    cp -r webs ss res scripts $koolshare_dir
    cp uninstall.sh $koolshare_dir/scripts/uninstall_v2ray.sh

    echo_date "复制版本号"
    cp Version $v2ray_dir

    if [ ! -f "$v2ray_dir/v2ray" ];then
        echo_date "检测到没有安装 v2ray，复制安装 v2ray"
        cp v2ctl v2ctl.sig v2ray v2ray.sig geoip.dat geosite.dat $v2ray_dir
    fi
}
main
CUR_VERSION=`cat $v2ray_dir/Version`
dbus set softcenter_module_v2ray_install=1
dbus set softcenter_module_v2ray_version="$CUR_VERSION"
dbus set softcenter_module_v2ray_title="科学上网v2ray插件"
dbus set softcenter_module_v2ray_description="科学上网v2ray插件"
dbus set softcenter_module_v2ray_home_url=Module_v2ray.asp
dbus set v2ray_module_version=$CUR_VERSION
