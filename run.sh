#!/usr/bin/env sh

ConfFile="/root/conf/config.yaml"

# 设置环境变量

dl-clash-conf $ConfFile
# 启动定时下载配置文件
if [[ ! -z "$CRON_EXPRESSION" ]]; then
  # 设置环境变量
  CRON_EXPRESSION="${CRON_EXPRESSION:-'1 * * * *'}"
  SCRIPT="update-clash-conf $ConfFile  >> /root/conf/cron_history 2>&1 &"
  # 清除现有的定时任务
  crontab -r || true
  crond -f &
  # 添加新的定时任务
  echo "$CRON_EXPRESSION $SCRIPT" | crontab -
fi

# 启动代理
ConfPath=`dirname $ConfFile`
/clash -d $ConfPath -f $ConfFile

