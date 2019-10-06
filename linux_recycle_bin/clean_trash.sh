#!/bin/bash
###############################################
# Filename    :   clear_trash.sh
# Author      :   PedroQin
# Email       :   pedroqin@gmail.com
# Date        :   2019-10-06 18:43:18
# Description :   
# Version     :   1.0.0
###############################################

trashdir=/tmp/trash
cd ${trashdir}
find ./ -mtime +3 -print0 |xargs -0 rm -rf {} \; 
