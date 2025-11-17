FROM caddy:2-alpine AS caddy
FROM teddysun/xray:latest

# Копируем Caddy
COPY --from=caddy /usr/bin/caddy /usr/bin/caddy

# Создаем директории
RUN mkdir -p /etc/xray /etc/caddy

# Создаем Caddyfile
RUN echo ':8080 {' > /etc/caddy/Caddyfile && \
    echo '    reverse_proxy /vmessws localhost:10086 {' >> /etc/caddy/Caddyfile && \
    echo '        header_up Host {host}' >> /etc/caddy/Caddyfile && \
    echo '        header_up X-Real-IP {remote}' >> /etc/caddy/Caddyfile && \
    echo '        header_up X-Forwarded-For {remote}' >> /etc/caddy/Caddyfile && \
    echo '        header_up X-Forwarded-Proto {scheme}' >> /etc/caddy/Caddyfile && \
    echo '    }' >> /etc/caddy/Caddyfile && \
    echo '    respond / "404 Not Found" 404' >> /etc/caddy/Caddyfile && \
    echo '}' >> /etc/caddy/Caddyfile

# Конфиг Xray
RUN echo '{' > /etc/xray/config.json && \
    echo '  "log": {' >> /etc/xray/config.json && \
    echo '    "loglevel": "info"' >> /etc/xray/config.json && \
    echo '  },' >> /etc/xray/config.json && \
    echo '  "inbounds": [' >> /etc/xray/config.json && \
    echo '    {' >> /etc/xray/config.json && \
    echo '      "port": 10086,' >> /etc/xray/config.json && \
    echo '      "listen": "127.0.0.1",' >> /etc/xray/config.json && \
    echo '      "protocol": "vmess",' >> /etc/xray/config.json && \
    echo '      "settings": {' >> /etc/xray/config.json && \
    echo '        "clients": [' >> /etc/xray/config.json && \
    echo '          {' >> /etc/xray/config.json && \
    echo '            "id": "b831381d-6324-4d53-ad4f-8cda48b30811",' >> /etc/xray/config.json && \
    echo '            "alterId": 0' >> /etc/xray/config.json && \
    echo '          }' >> /etc/xray/config.json && \
    echo '        ]' >> /etc/xray/config.json && \
    echo '      },' >> /etc/xray/config.json && \
    echo '      "streamSettings": {' >> /etc/xray/config.json && \
    echo '        "network": "ws",' >> /etc/xray/config.json && \
    echo '        "wsSettings": {' >> /etc/xray/config.json && \
    echo '          "path": "/vmessws"' >> /etc/xray/config.json && \
    echo '        }' >> /etc/xray/config.json && \
    echo '      }' >> /etc/xray/config.json && \
    echo '    }' >> /etc/xray/config.json && \
    echo '  ],' >> /etc/xray/config.json && \
    echo '  "outbounds": [' >> /etc/xray/config.json && \
    echo '    {' >> /etc/xray/config.json && \
    echo '      "protocol": "freedom",' >> /etc/xray/config.json && \
    echo '      "settings": {}' >> /etc/xray/config.json && \
    echo '    }' >> /etc/xray/config.json && \
    echo '  ]' >> /etc/xray/config.json && \
    echo '}' >> /etc/xray/config.json

# Startup script
RUN echo '#!/bin/sh' > /start.sh && \
    echo 'caddy run --config /etc/caddy/Caddyfile &' >> /start.sh && \
    echo 'exec xray run -c /etc/xray/config.json' >> /start.sh && \
    chmod +x /start.sh

EXPOSE 8080

CMD ["/start.sh"]