#!/bin/sh

V2RAY_DIR="/jffs/v2ray"
CUR_VER=`$V2RAY_DIR/v2ray -version 2>/dev/null | head -n 1 | cut -d " " -f2`

echo > /tmp/v2ray_status.log
echo "var v2ray_version={'cur_version':'${CUR_VER}'}" > /tmp/v2ray_status.log
echo "XU6J03M6" >> /tmp/v2ray_status.log
