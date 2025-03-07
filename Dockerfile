FROM dreamacro/clash-premium:latest


ADD https://cdn.jsdelivr.net/gh/Dreamacro/maxmind-geoip@release/Country.mmdb /root/files/Country.mmdb
ADD https://github.com/eorendel/clash-dashboard/archive/refs/heads/main.zip  /tmp/main.zip

WORKDIR /workspace

COPY ./app.bin  /bin/app

RUN apk add wget \
    curl \
    && chmod +x /bin/app \
    && unzip /tmp/main.zip -d /etc/clash-dashboard

ENTRYPOINT ["run"]

EXPOSE 8080

CMD ["app"]
