#!/bin/sh

PID_FILE=/usr/local/charcutio/charcutio.pid

if [ ! -z "$PID_FILE" ] && [ -s $PID_FILE ]; then
        echo "Killing: `cat $PID_FILE`"
        kill `cat $PID_FILE`
        rm $PID_FILE
else
        echo "Kill failed: \$PID_FILE not set or doesn't exist"
fi