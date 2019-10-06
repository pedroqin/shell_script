#!/bin/bash
###############################################
# Filename    :   abcd.sh
# Author      :   PedroQin
# Email       :   constmyheart@163.com
# Date        :   2019-08-04 21:11:47
# Description :   get the up/down/right/left keys
###############################################
 
# show message in green
function green_message()
{
    echo -ne "\033[32m$@\033[0m"
    echo
}

# show message in red
function red_message()
{
    echo -ne "\033[31m$@\033[0m"
    echo
}

function input_ch()
{
    declare -i len=0
    declare -i max_len=${1:-999}
    echo -ne "Please press direction key : "
    label=""
    while [ -z "$label" ]; do
        while ((1)); do
            read -s -n 1 ch
            dec=`printf "%d" "'$ch"`
            [ $dec -eq 0 ] && break
            if [ $dec -eq 8 -o $dec -eq 127 ] && [ $len -gt 0 ]; then
                echo -ne '\b \b'
                let len-=1
                [ $len -gt 0 ] && label=`echo $label | cut -c -$len`
                [ $len -eq 0 ] && label=""
            fi
            #[ $dec -lt 48 ] || [ $dec -gt 57 -a $dec -lt 65 ] || [ $dec -gt 90 -a $dec -lt 97 ] || [ $dec -gt 122 ] && continue
            [ $dec -lt 33 ] || [ $dec -gt 126 ] && continue
            echo -n ${ch}
            label="${label}""$ch"
            [ $dec -ge 48 -a $dec -le 57 ] || [ $dec -ge 65 -a $dec -le 90 ] || [ $dec -ge 97 -a $dec -le 122 ] && break
            let len+=1
            [ "$len" -ge "${max_len}" ] && break
        done
        echo
    done
    label=`echo $label | awk '{print toupper($0)}'`
}
while ((1));do
    input_ch 5
    sleep 0.1
    case $label in 
        w|W|[A)
        echo press $label/up
        ;;
        s|S|[B)
        echo press $label/down
        ;;
        d|D|[C)
        echo press $label/right
        ;;
        a|A|[D)
        echo press $label/left
        ;;
    esac
done
