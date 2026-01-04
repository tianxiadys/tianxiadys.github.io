#!/bin/bash
#
# loongcollectord        Control Script for loongcollector
#
# chkconfig: 2345 55 45
# description: loongcollector is log collect agent of Simple Log Service
#
# processname: loongcollectord
#
# version: 0.6

### BEGIN INIT INFO
# Provides:          alibabacloud
# Required-Start:
# Required-Stop:
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: loongcollector init script
# Description:       This file should be used to construct scripts to be placed in /etc/init.d.
#
### END INIT INFO

set -o pipefail

BIN_DIR="/usr/local/ilogtail"
INSTANCE_SUFFIX=""
BIN_DIR="$BIN_DIR$INSTANCE_SUFFIX"
SYSTEMD_SERVICE_NAME=""
SYSTEMD_SERVICE_DIR=""
BIN_DIR=$(readlink -f $BIN_DIR)
UMASK=${UMASK:-$(umask)}

killProcessGroup() {
    for pid in $*; do
        echo kill process $(grep "Name:" /proc/$pid/status) pid: $pid
        kill $pid
    done
}

forceKillProcessGroup() {
    for pid in $*; do
        echo force kill process $(grep "Name:" /proc/$pid/status) pid: $pid
        kill -9 $pid
    done
}

checkStatus() {
    PPIDS=()
    # Try get daemon PIDs from pid file
    local ppids_in_file=($(pgrep -l --pidfile "${BIN_DIR}/loongcollector.pid" 2>/dev/null | awk '{print $1}'))
    for ppid in ${ppids_in_file[*]}; do
        if stat /proc/$ppid/exe | grep -F "${BIN_DIR}/loongcollector" >/dev/null; then
            PPIDS=(${PPIDS[*]} $ppid)
        fi
    done
    # If pid file is empty, try get daemon PIDs by pgrep
    if [ ${#PPIDS[*]} == 0 ]; then
        PPIDS_RAW=($(pgrep -l -f -P 1,0 "loongcollector.*" | awk '{print $1}'))
        for ppid in ${PPIDS_RAW[*]}; do
            if stat /proc/$ppid/exe | grep -F "${BIN_DIR}/loongcollector" >/dev/null; then
                PPIDS=(${PPIDS[*]} $ppid)
            fi
        done

        local isInsideDocker=0
        for val in $(cat "/proc/1/cgroup" | awk -F":/" '{print $NF}'); do
            if [ "$val" != "" ]; then
                isInsideDocker=1
                break
            fi
        done
        # If on host machine, check and remove those in containers.
        if [ $isInsideDocker -eq 0 ]; then
            local INIT_PID_PATH="/proc/1/ns/pid"
            local initNsPid=""
            local hasNamespace=0
            if [ -f "$INIT_PID_PATH" ]; then
                initNsPid=$(stat $INIT_PID_PATH | head -n 1 | awk -F"-> " '{print $NF}')
                hasNamespace=1
            fi
            HOST_PPIDS=()
            for ppid in ${PPIDS[*]}; do
                # Has namespace, compare loongcollector with init process.
                if [ $hasNamespace -eq 1 ]; then
                    pidPath="/proc/$ppid/ns/pid"
                    if [ ! -f "$pidPath" ]; then
                        echo "no $pidPath, ignore $ppid"
                        continue
                    fi
                    nsPid=$(stat $pidPath | head -n 1 | awk -F"-> " '{print $NF}')
                    if [ "$initNsPid" == "$nsPid" ]; then
                        HOST_PPIDS=(${HOST_PPIDS[*]} $ppid)
                    else
                        echo "process in container ($initNsPid, $nsPid), ignore $ppid"
                    fi
                    continue
                fi

                # No namepsace, use devices to check.
                local devicesID=$(cat /proc/$ppid/cgroup | grep "devices:/" | awk -F":/" '{printf $NF}')
                if [ "$devicesID" != "" ]; then
                    echo "non-empty devices ID $devicesID, ignore $ppid"
                    continue
                fi
                HOST_PPIDS=(${HOST_PPIDS[*]} $ppid)
            done
            PPIDS=(${HOST_PPIDS[*]})
        fi
    fi

    PPIDS=($(echo "${PPIDS[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))
    CPIDS=()
    # Get worker pid from parent daemon
    for ppid in ${PPIDS[*]}; do
        CPIDS=(${CPIDS[*]} $(pgrep -l -x -P "$ppid" "loongcollecto.*" | awk '{print $1}'))
    done
    if [ ${#PPIDS[*]} == 0 ]; then
        return '1'
    fi
    if [ ${#PPIDS[*]} != 1 -o ${#CPIDS[*]} != 1 ]; then
        # ppid can be worker, if daemon exited
        echo loongcollector ppid: ${PPIDS[*]}, cpid: ${CPIDS[*]}
        return '2'
    else
        return '0'
    fi
}

checkStart() {
    checkStatus
    checkRst=$?
    if [ "$checkRst" == "0" ]; then
        echo "start successfully"
        RETVAL=0
    elif [ "$checkRst" == "1" ]; then
        echo "start failed"
        RETVAL=1
    else
        echo "loongcollector running process is abnormal"
        RETVAL=1
    fi
}

start() {
    # Check that SYSTEMD_SERVICE_NAME and SYSTEMD_SERVICE_DIR are not empty and systemd is available
    if [ -n "$SYSTEMD_SERVICE_NAME" ] && [ -n "$SYSTEMD_SERVICE_DIR" ] && systemctl --version &> /dev/null && [ -f "$SYSTEMD_SERVICE_DIR/$SYSTEMD_SERVICE_NAME" ]; then
        systemctl start "$SYSTEMD_SERVICE_NAME"
    else
        cd $BIN_DIR
        umask $UMASK
        $BIN_DIR/loongcollector -enable_host_id=false
    fi
    RETVAL=$?
}

stop() {
    checkStatus
    killProcessGroup ${PPIDS[*]}
    killProcessGroup ${CPIDS[*]}
    wait_seconds=0
    while [ $wait_seconds -lt 30 ]; do
        sleep 1
        let wait_seconds=wait_seconds+1
        checkStatus
        checkRst=$?
        if [ "$checkRst" == "1" ]; then
            break
        fi
    done
    if [ "$checkRst" == "1" ]; then
        rm -f "${BIN_DIR}/$REAL_BINARY.pid"
        echo "stop successfully"
        RETVAL=0
    else
        echo "graceful stop failed, you should retry stop or using force-stop"
        RETVAL=1
    fi
}

forceStop() {
    checkStatus
    forceKillProcessGroup ${PPIDS[*]}
    forceKillProcessGroup ${CPIDS[*]}
    checkStatus
    checkRst=$?
    if [ "$checkRst" == "1" ]; then
        rm -f "${BIN_DIR}/$REAL_BINARY.pid"
        echo "force stop successfully"
        RETVAL=0
    else
        echo "force stop failed"
        RETVAL=1
    fi
}

restart() {
    tryTime=0
    while [ $tryTime -lt 3 ]; do
        stop
        stopRst=$RETVAL
        if [ "$stopRst" == "0" ]; then
            break
        fi
        ((tryTime = tryTime + 1))
    done
    if [ "$tryTime" == "3" ]; then
        forceStop
    fi
    start
    sleep 0.2
    getStatus
}

getStatus() {
    checkStatus
    checkRst=$?
    if [ "$checkRst" == "0" ]; then
        echo "loongcollector is running"
        RETVAL=0
    elif [ "$checkRst" == "1" ]; then
        echo "loongcollector is stopped"
        RETVAL=3
    else
        echo "loongcollector running process is abnormal."
        RETVAL=1
    fi
}

case "$1" in
start)
    start
    sleep 0.2
    getStatus
    ;;
stop)
    stop
    ;;
force-stop)
    forceStop
    ;;
restart)
    restart
    ;;
status)
    getStatus
    ;;
-h)
    echo $"Usage: $0 { start | stop (graceful, flush data and save checkpoints) | force-stop | status | -h for help}"$
    RETVAL=$?
    ;;
*)
    echo $"Usage: $0 { start | stop (graceful, flush data and save checkpoints) | force-stop | status | -h for help}"
    RETVAL=1
    ;;
esac
exit $RETVAL
