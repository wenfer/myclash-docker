#!/usr/bin/env sh
# 下载配置文件

ConfFile=$1
ConfPath=`dirname $ConfFile`
mkdir -p $ConfPath
wget -O $ConfFile   -q  "$CONF_URL"
# 若文件下载失败, 则返回并报错
if [ $? -ne 0 ];
then
  echo "config file download fail"
  exit $?
fi



modify_config(){
  # 检查配置文件中是否包含指定的键
  if grep -Eq "^$1:" "$ConfFile"; then
    # 如果存在该键，则直接修改值
    sed -i "s/^$1:.*/$1: $2/" "$ConfFile"
    echo "已修改 $1 的值为 $2"
  else
    # 如果键不存在，则追加配置项
    echo "$1: $2" >> "$ConfFile"
    echo "配置项不存在，已添加新配置到 $ConfFile"
  fi
}


# 写入 API端口
if [[ ! -z "$EXTERNAL_BIND" && ! -z "$EXTERNAL_PORT" ]]
then
  modify_config "external-controller" "$EXTERNAL_BIND:$EXTERNAL_PORT"
  modify_config "external-ui" "ui"
fi
# 鉴权信息
if [[ ! -z "$EXTERNAL_SECRET" ]]
then
  modify_config "secret" "$EXTERNAL_SECRET"
fi
# 必须开启局域网连接, 否则外部无法连接
modify_config "allow-lan" "true"

sed -i "/^port:/d" "$ConfFile"
sed -i "/^socks-port:/d" "$ConfFile"

modify_config "mixed-port" "$SOCKET_PORT"

