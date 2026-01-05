#!/bin/bash
ACCOUNT_ID=$(curl -s http://100.100.100.200/latest/meta-data/owner-account-id)
REGION_ID=$(curl -s http://100.100.100.200/latest/meta-data/region-id)
export ALIYUN_LOGTAIL_CONFIG="/app/${REGION_ID}/ilogtail_config.json"
export ALIYUN_LOGTAIL_USER_ID="${ACCOUNT_ID}"
exec /app/loongcollector -enable_host_id=false -ilogtail_daemon_flag=false
