#!/bin/bash

/usr/sbin/squid -z
/usr/sbin/squid -N -f /etc/squid/squid.conf
