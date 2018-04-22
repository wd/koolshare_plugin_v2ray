#!/bin/sh

alias echo_date='echo 【$(TZ=UTC-8 date -R +%Y年%m月%d日\ %X)】:'

tmp_file="/tmp/v2ray.tar.gz"
download_link="https://www.dropbox.com/s/e7lfvft1vhljlc9/v2ray.tar.gz?dl=0 "
proxy=`dbus get v2ray_update_proxy`

download_plugin(){
    echo_date "下载最新的版本"
    curl ${proxy} -L -H "Cache-Control: no-cache" -o $tmp_file $download_link 2>&1
    if [ $? != 0 ];then
        echo_date "下载失败"
        return 1
    fi
    return 0
}

install_plugin(){
    echo_date "解压文件"
    tar zxvf $tmp_file -C "/tmp"
    if [[ $? -ne 0 ]]; then
        echo_date "解压失败"
        return 1
    fi
    sh /tmp/v2ray/install.sh
    rm -r /tmp/v2ray
    return 0
}

remove_tmp_file(){
    echo_date "清理临时文件"
    rm $tmp_file
}

function main(){
    echo_date "开始更新"
    download_plugin
    [ $? == 0 ] && install_plugin
    [ $? == 0 ] && remove_tmp_file
    echo_date "结束"
}

main > /tmp/v2ray_status.log
echo "O(∩_∩)O~" >> /tmp/v2ray_status.log
echo "XU6J03M6" >> /tmp/v2ray_status.log
