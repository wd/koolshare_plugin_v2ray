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

migrate_old_config(){
    echo_date "尝试迁移旧版本配置"
    old_v2ray_config=`dbus get ss_v2ray_config`
    v2ray_config=`dbus get v2ray_config`
    if [ -n "$old_v2ray_config" ] && [ -z "$v2ray_config" ];then
        echo_date "发现旧版配置，并且没有新版配置，迁移旧版配置"
        dbus set v2ray_config=$old_v2ray_config
    else
        echo_date "不需要迁移"
    fi

    echo_date "移除旧版配置"
    dbus remove ss_v2ray_config
    dbus remove ss_v2ray_enable
    dbus remove ss_v2ray_update_proxy
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
    cp -r webs res scripts $koolshare_dir
    cp uninstall.sh $koolshare_dir/scripts/uninstall_v2ray.sh

    echo_date "复制文件到 v2ray 目录"
    cp -r Version ss $v2ray_dir

    echo_date "建立 ss 插件的软链"
    ln -sf $v2ray_dir/ss/postscripts/P01v2ray.sh $koolshare_dir/ss/postscripts/P01v2ray.sh

    if [ ! -f "$v2ray_dir/v2ray" ];then
        echo_date "检测到没有安装 v2ray，复制安装 v2ray"
        cp v2ctl v2ctl.sig v2ray v2ray.sig geoip.dat geosite.dat $v2ray_dir
    else
        CUR_VER=`$v2ray_dir/v2ray -version 2>/dev/null | head -n 1 | cut -d " " -f2`
        echo_date "检测到已经安装 v2ray, 版本 $CUR_VER"
    fi
    migrate_old_config
}
main
CUR_VERSION=`cat $v2ray_dir/Version`
dbus set softcenter_module_v2ray_install=1
dbus set softcenter_module_v2ray_version="$CUR_VERSION"
dbus set softcenter_module_v2ray_title="科学上网v2ray插件"
dbus set softcenter_module_v2ray_description="科学上网v2ray插件"
dbus set softcenter_module_v2ray_home_url=Module_v2ray.asp
dbus set v2ray_module_version=$CUR_VERSION
