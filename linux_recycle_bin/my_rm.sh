#!/bin/bash
###############################################
# Filename    :   my_rm.sh
# Author      :   PedroQin
# Email       :   pedroqin@gmail.com
# Date        :   2019-10-06 14:58:56
# Description :   
# Version     :   1.0.0
###############################################

trash_dir_main="/tmp/trash"
trash_dir="$trash_dir_main"/`date +%Y%m%d`
[ ! -d ${trash_dir} ] && mkdir -p ${trash_dir}
upper_limit="$[5000*1024]" ## unit : K

#### for this script env vaiable
RECURSIVE=0
FORCE=0
PROMPT_ONCE=0 # exclusive with FORCE var
PROMPT=0 # exclusive with FORCE var
###
rm_cmd="rm -i"
mv_cmd="mv -i"
###

function confirm ()
{
    local ans=""
    local -i ret=0

    while [ -z "$ans" ]; do
        read -p "$1" ans
        boolean $ans
        ret=$?
        [ $ret -eq 255 ] && ans=""
    done
    #echo "$ans"

    return $ret
}

function boolean()
{
    case "$1" in
        [tT] | [yY] | [yY][eE][sS] | [tT][rR][uU][eE] | L6 | L10 | L12 )
        return 0
        ;;
        [fF] | [nN] | [nN][oO] | [fF][aA][lL][sS][eE])
        return 1
        ;;
    esac
    return 255
}

rm_index=0
while [ ! -z "$1" ];do
    case "$1" in
        -r|--recursive)
        RECURSIVE=1
        ;;

        -f|--force)
        FORCE=1
        ;;

        -fr|-rf)
        RECURSIVE=1
        FORCE=1
        ;;

        -i)
        PROMPT=1
        ;;

        -I)
        PROMPT_ONCE=1
        ;;

        *)
        let rm_index++
        dir_file[$rm_index]="$1"
        ;;

    esac
    shift
done


err_code=0
suffix=`date "+%H%M%S"`
#echo $rm_index
for i in `seq 1 $rm_index`
do
    dir_file_name=${dir_file[$i]}
    #echo $dir_file_name
    if [ ! -d "${dir_file_name}" ]&&[ ! -f "${dir_file_name}" ];then
        echo "[${dir_file_name}] do not exist"
        let err_code++
        continue
    else
        file_name=`basename "${dir_file_name}"`
        # check 
        if [ -d "$dir_file_name" -a ${RECURSIVE:-0} -eq 0 ] ;then
            echo cannot remove \'"${dir_file_name}"\' Is a directory
            let err_code++
            continue
        fi
        echo -n "summary size... "
        file_size=`du -sk "${dir_file_name}"|awk '{print $1}'`
        echo "$file_size k"
        # for large file/dir
        if [ "$file_size" -ge "$upper_limit" ];then
            if confirm "The file/dir size is $file_size > $upper_limit(upper_limit) ,delet it without mv to Trash?[Y|N]: " ;then
                rm_para=""
                [ "${RECURSIVE:-0}" -eq 1 ] && rm_para="$rm_para -r"
                [ "${FORCE:-0}" -eq 1 ] && rm_para="$rm_para -f"
                eval $rm_cmd "$rm_para" "${dir_file_name}" || let err_code++
                continue
            else
                continue
            fi 
        fi
        if [ "${FORCE:-0}" -eq 0 ];then
            if ! confirm "rm '"${dir_file_name}"'?[Y|N]: " ;then
                continue
            fi
        fi
        target_path=${trash_dir}/"${file_name}"_${suffix}_${RANDOM}
        eval $mv_cmd "${dir_file_name}" ${target_path}
        echo "[${dir_file_name}] delete completed, Trash path: ${target_path}" 
    fi
done
exit $err_code
