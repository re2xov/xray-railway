#!/bin/sh
xray run -c /etc/xray/config.json &
sleep 3
caddy run --config /etc/caddy/Caddyfile
```
