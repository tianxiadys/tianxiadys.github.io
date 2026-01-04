#!/bin/bash

##POSTFIX
CORP_POSTFIX="-corp"
INTERNET_POSTFIX="-internet"
INNER_POSTFIX="-inner"
FINANCE_POSTFIX="-finance"
ACCELERATION_POSTFIX="-acceleration"
INTERNAL_POSTFIX="-internal"

## REGION
CN_HANGZHOU="cn-hangzhou"
CN_HANGZHOU_INTERNET=$CN_HANGZHOU$INTERNET_POSTFIX
CN_HANGZHOU_FINANCE=$CN_HANGZHOU$FINANCE_POSTFIX
CN_HANGZHOU_FINANCE_INTERNET=$CN_HANGZHOU_FINANCE$INTERNET_POSTFIX
CN_HANGZHOU_INNER=$CN_HANGZHOU$INNER_POSTFIX
CN_HANGZHOU_ACCELERATION=$CN_HANGZHOU$ACCELERATION_POSTFIX
CN_SHENZHEN="cn-shenzhen"
CN_SHENZHEN_INTERNET=$CN_SHENZHEN$INTERNET_POSTFIX
CN_SHENZHEN_FINANCE=$CN_SHENZHEN$FINANCE_POSTFIX
CN_SHENZHEN_FINANCE_INTERNET=$CN_SHENZHEN_FINANCE$INTERNET_POSTFIX
CN_SHENZHEN_INNER=$CN_SHENZHEN$INNER_POSTFIX
CN_SHENZHEN_ACCELERATION=$CN_SHENZHEN$ACCELERATION_POSTFIX
CN_SHANGHAI="cn-shanghai"
CN_SHANGHAI_INTERNET=$CN_SHANGHAI$INTERNET_POSTFIX
CN_SHANGHAI_INNER=$CN_SHANGHAI$INNER_POSTFIX
CN_SHANGHAI_FINANCE=$CN_SHANGHAI$FINANCE_POSTFIX
CN_SHANGHAI_FINANCE_INTERNET=$CN_SHANGHAI_FINANCE$INTERNET_POSTFIX
CN_SHANGHAI_ACCELERATION=$CN_SHANGHAI$ACCELERATION_POSTFIX

PACKAGE_ADDRESS=""
KERNEL_VERSION=$(uname -r)
ARCH=$(uname -m)

exit_handle()
{
    echo 'receive stop signal, sleep ' $delaySec
    sleep $delaySec
    echo stop loongcollector
    /etc/init.d/loongcollectord stop
    echo stop loongcollector done, result $?
    if [ "$ALIYUN_LOGTAIL_POST_RUN_CMD" ]; then
        echo 'execute cmd before loongcollector start : ' $ALIYUN_LOGTAIL_POST_RUN_CMD
        $ALIYUN_LOGTAIL_POST_RUN_CMD
    fi
    exit 0
}

function detectRegion () {
    if [[ "$ALIYUN_LOGTAIL_OSS_ADDRESS" != "" ]]; then
        PACKAGE_ADDRESS=$ALIYUN_LOGTAIL_OSS_ADDRESS
    fi
    REGION="cn-hangzhou"
    if [[ $1 != "" ]]; then
        REGION=`echo $1 | awk -F "/" '{print $5}'`
    fi

    local package_address=""
    if [ "$(echo $REGION | grep "\b$CN_HANGZHOU_FINANCE_INTERNET\b" | wc -l)" -ge 1 ]; then
        package_address="http://aliyun-observability-release-cn-hangzhou-finance-1.oss-cn-hzfinance.aliyuncs.com/loongcollector"
    elif [ "$(echo $REGION | grep "\b$CN_HANGZHOU_FINANCE\b" | wc -l)" -ge 1 ]; then
        package_address="http://aliyun-observability-release-cn-hangzhou-finance-1.oss-cn-hzfinance-internal.aliyuncs.com/loongcollector"
    elif [ "$(echo $REGION | grep "\b$CN_SHENZHEN_FINANCE_INTERNET\b" | wc -l)" -ge 1 ]; then
        package_address="http://aliyun-observability-release-sz-finance.oss-cn-shenzhen-finance-1.aliyuncs.com/loongcollector"
    elif [ "$(echo $REGION | grep "\b$CN_SHENZHEN_FINANCE\b" | wc -l)" -ge 1 ]; then
        package_address="http://aliyun-observability-release-sz-finance.oss-cn-shenzhen-finance-1-internal.aliyuncs.com/loongcollector"
    elif [ "$(echo $REGION | grep "\b$CN_SHANGHAI_FINANCE_INTERNET\b" | wc -l)" -ge 1 ]; then
        package_address="http://aliyun-observability-release-cn-shanghai-finance-1.oss-cn-shanghai-finance-1.aliyuncs.com/loongcollector"
    elif [ "$(echo $REGION | grep "\b$CN_SHANGHAI_FINANCE\b" | wc -l)" -ge 1 ]; then
        package_address="http://aliyun-observability-release-cn-shanghai-finance-1.oss-cn-shanghai-finance-1-internal.aliyuncs.com/loongcollector"
    elif [ "$(echo $REGION | grep "\b$INTERNET_POSTFIX\b" | wc -l)" -ge 1 ] ||
        [ "$(echo $REGION | grep "\b$ACCELERATION_POSTFIX\b" | wc -l)" -ge 1 ]; then
        local region_id
        region_id=$(echo $REGION | sed "s/$INTERNET_POSTFIX//g")
        region_id=$(echo $region_id | sed "s/$ACCELERATION_POSTFIX//g")
        package_address="http://aliyun-observability-release-$region_id.oss-$region_id.aliyuncs.com/loongcollector"
    elif [ "$(echo $REGION | grep "\b$INNER_POSTFIX\b" | wc -l)" -ge 1 ]; then
        package_address="http://aliyun-observability-release-cn-hangzhou.oss-cn-hangzhou.aliyuncs.com/loongcollector"
    elif [ "$(echo $REGION | grep "\b$INTERNAL_POSTFIX\b" | wc -l)" -ge 1 ]; then
        local region_id
        region_id=$(echo $REGION | sed "s/$INTERNAL_POSTFIX//g")
        package_address="http://aliyun-observability-release-$region_id.oss-$region_id-internal.aliyuncs.com/loongcollector"
    else
        package_address="http://aliyun-observability-release-$REGION.oss-$REGION-internal.aliyuncs.com/loongcollector"
    fi

    PACKAGE_ADDRESS="$package_address/linux64"
    echo "detect the oss address is $PACKAGE_ADDRESS"
}


download_vmlinux() {
    rm -f /tmp/logtail_vmlist
    rm -rf /tmp/logtail-vmlinux
    mkdir -p /tmp/logtail-vmlinux

    curl -s "$PACKAGE_ADDRESS/vmlinux/$ARCH/list" --connect-timeout 3 -o /tmp/logtail_vmlist
    if [ $? != 0 ]; then
       echo "Download loongcollector mlist file from $PACKAGE_ADDRESS failed."
       return 1
    fi

    vmlinux_version=$(cat /tmp/logtail_vmlist | grep $KERNEL_VERSION)

    if [ "$vmlinux_version" = "" ]; then
        echo unmatch os version:$kernel_version,try find nearest vmlinux version
        cal_last_version
    fi

    if [ "$vmlinux_version" == "" ]; then
        echo unmatch os version:$kernel_version
        return 1
    else
        echo vmlinux version:$vmlinux_version
        curl -s  "$PACKAGE_ADDRESS"/vmlinux/$ARCH/$vmlinux_version --connect-timeout 10 -o /tmp/logtail-vmlinux/$vmlinux_version
        if [ $? != 0 ]; then
            echo "Download loongcollector vmlinux file from $PACKAGE_ADDRESS failed."
            echo "Please confirm the region you specified and try again."
            return 1
        fi
        cp /tmp/logtail-vmlinux/$vmlinux_version /usr/local/ilogtail/$vmlinux_version
    fi
    return 0
}


function calNeedDownloadBtf(){
    kernel_version=$(uname -r |awk -F '[-.]' '{print ($1*1000000000)+($2*1000000)+($3*1000)+($4)}')
    if [[ $kernel_version -gt 5004000000 ]]; then
         echo "your kernel version $kernel_version is over 5.04, so btf download process would be ignored."
         return 1
    else
         return 0
    fi
}

function cal_last_version() {
    rm -f /tmp/logtail_vmlist_sort
    curl -s $PACKAGE_ADDRESS/vmlinux/$ARCH/version_sortlist --connect-timeout 3 -o /tmp/logtail_vmlist_sort
    kernel_version=$(uname -r)
    os_vm_version=$(echo v-$kernel_version | awk -F '[-.]' '{print ($2*1000000000000)+($3*10000000000)+($4*10000000)+($5*1000)+($6*10)+($7)}')
    vmlinux_version=""
    while read line; do
        cur_vm_version=($(echo $line | awk -F ' ' '{print $1" "$2 }'))

        if [ $os_vm_version -gt ${cur_vm_version[0]} ]; then
            vmlinux_version=${cur_vm_version[1]}
        else
            return
        fi
    done </tmp/logtail_vmlist_sort
}



trap 'exit_handle' SIGTERM

delaySec=0

if [ $# -gt 0 ];then
    delaySec=$1
fi

echo 'delay stop seconds : ' $delaySec

if [[ $ALICLOUD_LOG_ECS_FLAG = "true" ]]; then
    echo "skip unmount "
else
    if [[ $ALIYUN_LOGTAIL_UNMOUNT_REGEX ]]; then
        echo 'start umount useless mount points, '  $ALIYUN_LOGTAIL_UNMOUNT_REGEX
        cat /proc/self/mountinfo | awk '{print $5}' | grep '^/' | grep -E $ALIYUN_LOGTAIL_UNMOUNT_REGEX | grep -v '/dev/' | xargs umount -l  > /dev/null 2>&1
    else
        echo 'start umount useless mount points, /shm$|/merged$|/mqueue$|volumes/kubernetes'
        cat /proc/self/mountinfo | awk '{print $5}' | grep '^/' | grep -E '/shm$|/merged$|/mqueue$|volumes/kubernetes' | grep -v '/dev/' | xargs umount -l  > /dev/null 2>&1
    fi
    echo 'umount done'
fi

if [ "$ALIYUN_LOGTAIL_PRE_RUN_CMD" ]; then
    echo 'execute cmd before loongcollector start : ' $ALIYUN_LOGTAIL_PRE_RUN_CMD
    $ALIYUN_LOGTAIL_PRE_RUN_CMD
fi


if [ "$ALIYUN_LOGTAIL_CONFIG" = "" ]; then
    echo "no logtail config, use default config : /etc/ilogtail/conf/cn_hangzhou/ilogtail_config.json"
    cp /etc/ilogtail/conf/cn_hangzhou/ilogtail_config.json /usr/local/ilogtail/ilogtail_config.json
fi

if [ "$ALIYUN_LOGTAIL_OBSERVER" != "" ]; then
    calNeedDownloadBtf
    if [ $? = 0 ]; then
        detectRegion $ALIYUN_LOGTAIL_CONFIG
        download_vmlinux
        if [ $? != 0 ]; then
            echo "loongcollector ebpf observer feature would not work"
        fi
    fi
fi

if [ -d "/etc/ilogtail/agent-install/start" ]; then
    cp -r /etc/ilogtail/agent-install/start/* /etc/ilogtail
fi

echo start loongcollector
/etc/init.d/loongcollectord start

echo loongcollector status:
/etc/init.d/loongcollectord status

while true
do
    sleep 3
done
#IMAGE_ID:6767526
