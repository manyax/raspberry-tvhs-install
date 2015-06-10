#!/bin/bash
if ! [ $(id -u) = 0 ]; then
   echo "You must be root to do this." 1>&2
   exit 100
else
   cd /opt
	git clone https://github.com/tvheadend/tvheadend.git
	cd tvheadend
	./configure
	make
	make install
	groupadd tvheadend
	useradd -g tvheadend -G video -m tvheadend
	touch  /etc/init.d/tvheadend
	cat <<EOF > /etc/init.d/tvheadend
#! /bin/sh
### BEGIN INIT INFO
# Provides:         tvheadend 
# Required-Start:
# Required-Stop:
# Should-Start:      
# Default-Start:     S
# Default-Stop:
# Short-Description: tvheadend init
# Description:       tvheadend
### END INIT INFO

TVHNAME="tvheadend"
TVHBIN="/usr/local/bin/tvheadend"
TVHUSER="tvheadend"
TVHGROUP="tvheadend"

case "$1" in
  start)
    echo "Starting tvheadend"
    start-stop-daemon --start --user ${TVHUSER} --exec ${TVHBIN} -- \
                -u ${TVHUSER} -g ${TVHGROUP} -f -C
  ;;
  stop)
    echo "Stopping tvheadend"
    start-stop-daemon --stop --quiet --name ${TVHNAME} --signal 2
  ;;
  restart)
    echo "Restarting tvheadend"

    start-stop-daemon --stop --quiet --name ${TVHNAME} --signal 2


    start-stop-daemon --start --user ${TVHUSER} --exec ${TVHBIN} -- \
                -u ${TVHUSER} -g ${TVHGROUP} -f -C

  ;;
  *)
    echo "Usage: tvheadend {start|stop|restart}"
    exit 1
esac
exit 0
EOF
	chmod 755 /etc/init.d/tvheadend
	update-rc.d tvheadend defaults
	echo "Starting TVHS without creditials"
	echo "Navigate to http://<rasppi_ip>:9981"
	/usr/local/bin/tvheadend --noacl
fi
exit 0
