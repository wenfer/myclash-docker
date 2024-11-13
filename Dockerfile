FROM dreamacro/clash:latest

ARG CLASH_VERSION="v1.18.0"

ADD https://cdn.jsdelivr.net/gh/Dreamacro/maxmind-geoip@release/Country.mmdb /root/conf/Country.mmdb
ADD https://github.com/haishanh/yacd/archive/gh-pages.zip  /root/conf/yacd.zip
COPY ./run.sh /bin/run
COPY ./dl-clash-conf.sh /bin/dl-clash-conf
COPY ./update-clash-conf.sh /bin/update-clash-conf

# 配置文件地址
ENV CONF_URL=http://test.com
# RESTful API 地址, 可为空
ENV EXTERNAL_BIND="0.0.0.0"
ENV EXTERNAL_PORT="9090"
# RESTful API 鉴权
ENV "EXTERNAL_SECRET"="123456"
ENV CRON_EXPRESSION="1 * * * *"
ENV SOCKET_PORT=7890

RUN apk add wget \
    curl \
    && chmod +x /bin/run \
    && chmod +x /bin/update-clash-conf \
    && chmod +x /bin/dl-clash-conf \
    && cd  /root/conf/ \
    && unzip yacd.zip \
    && mv yacd-gh-pages ui \
    && rm -rf yacd.zip

ENTRYPOINT ["run"]
