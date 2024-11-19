clash镜像构建脚本

- 定时任务自动更新订阅
- 集成ui界面 yacd
- 自动重写config.yaml配置用于局域网代理


```yaml
services:
  myclash:
    image: qiuyuan1992/myclash:latest
    container_name: myclash
    restart: unless-stopped
    ports:
      - 9090:9090 # ui端口
      - 7890:7890 # 代理端口
    volumes:
      - ./conf:/root/conf
    environment:
      - TZ=Asia/Shanghai
      - CRON_EXPRESSION=0 2 * * * # 每天凌晨2点 定时任务更新订阅
      - CONF_URL=https://test.com # 务必替换成你的订阅地址
      - EXTERNAL_BIND=0.0.0.0 # 绑定网卡ip，可以不写
      - EXTERNAL_PORT=9090  # ui端口
      - EXTERNAL_SECRET=123456  # ui密码

```


