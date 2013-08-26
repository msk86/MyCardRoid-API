#!/bin/bash

#server start
#server stop

thin $1 -Cthin.yml

if [ $YGOROID_API_ENV = production ] ; then
    if [ $1 = start ] ; then
        crontab cdb.cron
    elif [ $1 = stop ] ; then
        crontab -r
    fi
fi