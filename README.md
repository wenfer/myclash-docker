![image](https://github.com/user-attachments/assets/c9777b56-6d0c-4965-aa08-0eed783812cb)clash镜像构建脚本

# 2025/5/24更新
新增了arm64的镜像，需要换成ghcr.io的仓库，dockerhub拉不到


## 示例

- 定时任务自动更新订阅
- 集成ui界面 yacd
- 自动重写config.yaml配置用于局域网代理


```yaml
services:
  myclash:
    image: ghcr.io/wenfer/myclash-docker:main
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


