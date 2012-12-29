#!/bin/sh

APP_DIR=/usr/local/charcutio/current
LOG_FILE=/usr/local/charcutio/charcutio.log
PID_FILE=/usr/local/charcutio/charcutio.pid

exec ruby $APP_DIR/charcutio.rb >> "$LOG_FILE" 2>&1 &
echo $! > $PID_FILE

