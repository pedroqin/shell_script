#!/bin/bash
###############################################
# Filename    :   format_json.sh
# Author      :   PedroQin
# Date        :   2020-04-22 18:33:35
# Description :   
# Version     :   1.0.1
###############################################
 
# you can diy indent ,like "\t or "  "
indent="  "

##############################################
indent_num=0
indent_str=""
double_quotes=false
#A string is a sequence of zero or more Unicode characters, wrapped in double quotes, using backslash escapes. A character is represented as a single character string. A string is very much like a C or Java string. --- by https://www.json.org/json-en.html ,so single quote is not accepted !
#single_quote=false
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

function judge_char()
{
    case "$1" in
        "{")
        [ "$double_quotes" == "true" ] && echo -n "$1" && return
        let indent_num++
        combining_indent +
        echo "{"
        echo -ne "$indent_str"
        ;;
        
        "}")
        [ "$double_quotes" == "true" ] && echo -n "$1" && return
        let indent_num--
        combining_indent -
        echo
        echo -ne "$indent_str}"
        ;;
        
        "[")
        [ "$double_quotes" == "true" ] && echo -n "$1" && return
        let indent_num++
        combining_indent +
        echo "["
        echo -ne "$indent_str"
        ;;
        
        "]")
        [ "$double_quotes" == "true" ] && echo -n "$1" && return
        let indent_num--
        combining_indent -
        echo
        echo -ne "$indent_str]"
        ;;
        
        ",")
        [ "$double_quotes" == "true" ] && echo -n "$1" && return
        echo ","
        echo -ne "$indent_str"
        ;;
        
        '"')
        [ "$double_quotes" == "true" ] && double_quotes=false || double_quotes=true
        echo -n '"'
        ;;
        
        ":")
        [ "$double_quotes" == "false" ] && echo -n " : " || echo -n ":"
        ;;
        
        "\\")
        # if get \ ,will skip the next char, mostly it is \n
        [ "$double_quotes" == "false" ] && let offset++ || echo -n "\\"
        ;;
        
        *)
        echo -n "$1"
        ;;

    esac
}

function combining_indent()
{
    if [ $indent_num -lt 0 ];then
        red_message "Wrong Json format!"
        exit 255
    fi
    case $1 in
        +)
        indent_str+=$indent
        ;;
        -)
        indent_str=${indent_str%"$indent"}
        ;;

    esac
}

function usage()
{
    cat << USAGE
$0 -f \$json_file
$0 \$json_str
USAGE
    exit 255
}

if [ "$1" == "-f" ] || [ "$1" == "--file"  ];then
    file_name=$2
    [ ! -f "$file_name" ] && red_message "Can't find the file :$file_name" && usage
    strings="$(cat $file_name)"
else
    strings="$@"
fi

ifs_bak="$IFS"
IFS=$'\n'
offset=0
while ((1)); do
    ch="${strings:$offset:1}"
    judge_char "$ch"
    [ -z "$ch" ] && break
    let offset++
done
IFS="$ifs_bak"
echo
