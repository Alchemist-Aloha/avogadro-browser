#!/bin/bash
export DISPLAY=:1
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
