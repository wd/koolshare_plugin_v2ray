#!/bin/sh

alias echo_date='echo 【$(TZ=UTC-8 date -R +%Y年%m月%d日\ %X)】:'

v2ray_dir='/jffs/v2ray/'
koolshare_dir="/koolshare"

echo_date "移除定时任务"
sed -i '/v2raywatchdog/d' /var/spool/cron/crontabs/*

echo_date "移除 koolshare 目录文件"
rm -rf $koolshare_dir/scripts/v2ray_*.sh
rm -rf $koolshare_dir/res/v2ray*
rm -rf $koolshare_dir/webs/Module_v2ray.asp
rm -rf $koolshare_dir/ss/postscripts/P01v2ray.sh

echo_date "移除版本号文件"
rm -rf $v2ray_dir/Version

echo_date "--------------------"
echo_date "注意：程序不会移除 $v2ray_dir，如果需要清理请手动删除"
echo_date "--------------------"

dbus remove softcenter_module_v2ray_install
dbus remove softcenter_module_v2ray_version
dbus remove softcenter_module_v2ray_title
dbus remove softcenter_module_v2ray_description
dbus remove softcenter_module_v2ray_home_url
dbus remove v2ray_module_version
dbus remove v2ray_enable
