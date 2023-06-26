#!/bin/bash

#cp -p /proc/self/mounts /etc/mtab

cd /etc
ln -s /proc/mounts mtab

cd /usr/local/ncpa
./ncpa_posix_listener --start
