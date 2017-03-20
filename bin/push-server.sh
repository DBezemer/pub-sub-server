#!/bin/bash
#
# An init.d script for running a Node.js process as a service using Forever as
# the process monitor. For more configuration options associated with Forever,
# see: https://github.com/nodejitsu/forever

echo `date`

#
# push-server              This shell script takes care of starting and stopping a Kaltura push-server Service
#
# description: Kaltura push-server

### BEGIN INIT INFO
# Required-Start:    $local_fs $remote_fs $network
# Required-Stop:     $local_fs $remote_fs $network
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Start/stop Kaltura push-server
# Description:       Control the Kaltura push-server.
### END INIT INFO
 
NAME="push_server"
PUB_SUB_PATH="/opt/kaltura/pub-sub-server/latest"
LOG_PATH="/opt/kaltura/log"
NODE_PATH= $PUB_SUB_PATH"/node_modules"
APPLICATION_PATH= $PUB_SUB_PATH"/main.js"
PIDFILE= $PUB_SUB_PATH"/config/push-server.pid"
LOGFILE= $LOG_PATH"/push-server.log"
MIN_UPTIME="5000"
SPIN_SLEEP_TIME="2000"
 
PATH=$NODE_BIN_DIR:$PATH
export NODE_PATH=$NODE_PATH
 
start() {
    echo "Starting $NAME"
    forever \
      --pidFile $PIDFILE \
      -a \
      -l $LOGFILE \
      --minUptime $MIN_UPTIME \
      --spinSleepTime $SPIN_SLEEP_TIME \
      start "--max-old-space-size=3072 --nouse-idle-notification" $APPLICATION_PATH 2>&1 > /dev/null &
    RETVAL=$?
}
 
stop() {
    if [ -f $PIDFILE ]; then
        echo "Shutting down $NAME"
        # Tell Forever to stop the process.
        forever stop $APPLICATION_PATH 2>&1 > /dev/null
        # Get rid of the pidfile, since Forever won't do that.
        rm -f $PIDFILE
        RETVAL=$?
    else
        echo "$NAME is not running."
        RETVAL=0
    fi
}
 
restart() {
    stop
    start
}
 
status() {
    echo `forever list` | grep -q "$APPLICATION_PATH"
    if [ "$?" -eq "0" ]; then
        echo "$NAME is running."
        RETVAL=0
    else
        echo "$NAME is not running."
        RETVAL=3
    fi
}

logRotated() {
        if [ -f $PIDFILE ]; then
                echo "Notify log rotate for $NAME."
                kill -USR1 `cat $PIDFILE`
                RETVAL=1
        else
                echo "$NAME is not running."
                RETVAL=0
        fi
}
 
case "$1" in
    start)
        start
        ;;
    stop)
        stop
        ;;
    status)
        status
        ;;
    restart)
        restart
        ;;
 	logRotated)
        logRotated
        ;;

    *)
        echo "Usage: {start|stop|status|restart|logRotated}"
        exit 1
        ;;
esac
exit $RETVAL
