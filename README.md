clash镜像构建脚本

- 定时任务自动更新订阅
- 集成ui界面
- 重写config.yaml配置用于局域网代理


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
      - CRON=0 2 * * * # 每天凌晨2点 定时任务更新订阅
      - CONF_URL=https://test.com
      - EXTERNAL_BIND=0.0.0.0
      - EXTERNAL_PORT=9090
      - EXTERNAL_SECRET=123456

```


