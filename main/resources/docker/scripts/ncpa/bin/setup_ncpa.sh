#!/bin/bash

dpkg -i /local/packages/libssl1.0.0_1.0.2n-1ubuntu5.13_amd64.deb \
  /local/packages/ncpa-1.8.1-1.amd64.deb

/usr/local/ncpa/ncpa_posix_listener --stop

mv /usr/local/ncpa/etc/ncpa.cfg /usr/local/ncpa/etc/ncpa.cfg_old
mv /local/scripts/ncpa/properties/ncpa.cfg /usr/local/ncpa/etc/
mkdir /usr/local/ncpa/plugins/tmp
chown -R root:root /usr/local/ncpa/

mv /local/scripts/ncpa/bin/* /usr/local/ncpa/plugins
mv /local/scripts/ncpa/lib /usr/local/ncpa/plugins
