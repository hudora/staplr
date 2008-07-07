#!/bin/sh
cd /staplr

date > /var/log/runlog

/usr/local/bin/lua vst.lua 1 >> /var/log/runlog3 2>&1

return 0
