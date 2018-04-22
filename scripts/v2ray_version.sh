#!/bin/sh

CUR_VER=""
NEW_VER=""
ARCH=""
VDIS="arm"
ZIPFILE="/tmp/v2ray/v2ray.zip"
V2RAY_DIR="/jffs/v2ray"

CMD_INSTALL=""
CMD_UPDATE=""
SOFTWARE_UPDATED=0

alias echo_date='echo 【$(TZ=UTC-8 date -R +%Y年%m月%d日\ %X)】:'
PROXY=`dbus get v2ray_update_proxy`

sysArch(){
    ARCH=$(uname -m)
    if [[ "$ARCH" == "i686" ]] || [[ "$ARCH" == "i386" ]]; then
        VDIS="32"
    elif [[ "$ARCH" == *"armv7"* ]] || [[ "$ARCH" == "armv6l" ]]; then
        VDIS="arm"
    elif [[ "$ARCH" == *"armv8"* ]] || [[ "$ARCH" == "aarch64" ]]; then
        VDIS="arm64"
    elif [[ "$ARCH" == *"mips64le"* ]]; then
        VDIS="mips64le"
    elif [[ "$ARCH" == *"mips64"* ]]; then
        VDIS="mips64"
    elif [[ "$ARCH" == *"mipsle"* ]]; then
        VDIS="mipsle"
    elif [[ "$ARCH" == *"mips"* ]]; then
        VDIS="mips"
    elif [[ "$ARCH" == *"s390x"* ]]; then
        VDIS="s390x"
    fi
    return 0
}

# 1: new V2Ray. 0: no
getVersion(){
    CUR_VER=`$V2RAY_DIR/v2ray -version 2>/dev/null | head -n 1 | cut -d " " -f2`
    TAG_URL="https://api.github.com/repos/v2ray/v2ray-core/releases/latest"
    NEW_VER=`curl ${PROXY} -s ${TAG_URL} --connect-timeout 10| grep 'tag_name' | cut -d\" -f4`

    if [[ $? -ne 0 ]] || [[ "$NEW_VER" == "" ]]; then
        return -1 # Unknown
    elif [[ "$NEW_VER" != "$CUR_VER" ]];then
        return 1 # new version
    fi
    return 0
}

main() {
    sysArch
    getVersion
    if [[ $? != -1 ]]; then
        echo -e "var v2ray_version={'update':$?,'new_version':'${NEW_VER}','cur_version':'${CUR_VER}'}"
    else
	echo "{}"
    fi
}

echo > /tmp/v2ray_status.log
main > /tmp/v2ray_status.log 
echo "XU6J03M6" >> /tmp/v2ray_status.log
