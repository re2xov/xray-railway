FROM caddy:2-alpine AS caddy
FROM teddysun/xray:latest

COPY --from=caddy /usr/bin/caddy /usr/bin/caddy

COPY config.json /etc/xray/config.json
COPY Caddyfile /etc/caddy/Caddyfile

RUN echo '#!/bin/sh' > /start.sh && \
    echo 'xray run -c /etc/xray/config.json &' >> /start.sh && \
    echo 'sleep 3' >> /start.sh && \
    echo 'caddy run --config /etc/caddy/Caddyfile' >> /start.sh && \
    chmod +x /start.sh

EXPOSE 8080

CMD ["/start.sh"]