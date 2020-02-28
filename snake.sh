#!/bin/bash
###############################################
# Filename    :   snake.sh
# Author      :   PedroQin
# Email       :   constmyheart@163.com
# Date        :   2020-02-28 10:47:19
# Description :   
# Version     :   1.0.0
###############################################

# user-defined
begin_direction=left
length=50
height=15
if_go_through_the_wall=1
# snake speed
flash_time=0.40
min_flash_time=0.15
# if the snake speed up per 5 score
more_difficult=1
# when more_difficult=1, current speed = flash_time - score/5 * rising_rate > min_flash_time
rising_rate=0.03
# define the snake
snake_head="+"
snake="@"
egg="@"

##########################
# trap the kill singal
trap 'clean_env' SIGTERM
# some flag
flag_file=/tmp/snake_game.log
finish_flag=/tmp/snake_game_fail.log

max_blocks=`echo "$length*$height"|bc`
border="#"
space=" "
score=0

# prepare
begin_y=`echo "$height/2"|bc`
begin_x=`echo "$length/2"|bc`
help_msg="
Press 'q' to quit
Press 'c' to retry
Press 'p' to pause and any other key to resume
"
function display_info()
{
    display_str="$1
$help_msg"

    line_num=`echo "$display_str"|wc -l`
    for i in `seq 1 $line_num`;do
        str_line=`echo "$display_str"|sed -n "$i"p`
        str_len=`expr length "$str_line"`
        str_x=`echo "$begin_x - $str_len / 2 "|bc`
        str_y=`echo "$begin_y - $line_num / 2 + $i "|bc`
        tput cup $str_y $str_x
        echo -n "$str_line"
    done
}

function clean_env()
{
    rm $flag_file 2>/dev/null
    # unhide cursor
    tput cnorm
    # reposit cursor
    tput cup $[height+1] 0
    echo
    echo "finished."
    exit
}

function lay_egg()
{
    has_egg=0
    while [ "$has_egg" -eq 0 ]; do
        egg_x=`echo "$RANDOM%$length + 1" |bc`
        egg_y=`echo "$RANDOM%$height + 1" |bc`
        has_egg=1
        # the egg can't in the snake
        for i in ${snakes[@]};do
            [ "$i" == "$egg_x,$egg_y" ] && has_egg=0
        done
    done
    tput cup $egg_y $egg_x
    echo -n "$egg"

}

function finish()
{
    touch $finish_flag
    display_info "$1" 
}

function game()
{
    snakes=( "$[begin_x-1],$begin_y" "$begin_x,$begin_y" "$[begin_x+1],$begin_y")
    lay_egg
    previous_direction="$begin_direction"
    while ((1)) ;do
        # calculate per loop
        pre_snake=${snakes[0]}
        x0=${snakes[0]%%,*}
        y0=${snakes[0]##*,}
        direction=`cat $flag_file 2>/dev/null`
        direction="${direction:-$previous_direction}"
        [ -e $flag_file ] && rm $flag_file
        case ${direction:-$begin_direction} in 
            up)
            y0=$[ ${snakes[0]##*,} - 1 ]
            if [ $y0 -le 0 ] ;then
                if [ $if_go_through_the_wall -eq 0 ] ;then
                    finish "Your Score: $score"  && return
                else
                    let y0=$y0+$height
                fi
            fi
            ;;

            left)
            x0=$[ ${snakes[0]%%,*} - 1 ]
            if [ $x0 -le 0 ] ;then
                if [ $if_go_through_the_wall -eq 0 ] ;then
                    finish "Your Score: $score"  && return
                else
                    let x0=$x0+$length
                fi
            fi
            ;;

            down)
            y0=$[ ${snakes[0]##*,} + 1 ]
            if [ $y0 -gt $height ] ;then
                if [ $if_go_through_the_wall -eq 0 ] ;then
                    finish "Your Score: $score"  && return
                else
                    let y0=$y0-$height
                fi
            fi
            ;;

            right)
            x0=$[ ${snakes[0]%%,*} + 1 ]
            if [ $x0 -gt $length ] ;then
                if [ $if_go_through_the_wall -eq 0 ] ;then
                    finish "Your Score: $score"  && return
                else
                    let x0=$x0-$length
                fi
            fi
            ;;

            pause)
            while [ ! -f "$flag_file" ];do
                sleep $flash_time
            done
            continue
            ;;

            *)
            continue
            ;;

        esac
        previous_direction="$direction"
        # clear the last one and draw the first one,like snake crawl
        tput cup ${snakes[$[${#snakes[@]}-1]]##*,} ${snakes[$[${#snakes[@]}-1]]%%,*}
        echo -n "$space"
        # calculate the snakes
        snakes[0]="$x0,$y0"
        for i in `seq 1 $[ ${#snakes[@]} - 1]`;do
            # snake eat itself
            [ "${snakes[0]}" == "${snakes[$i]}" ] && finish "Your Score: $score" && return
            transition_value=${snakes[$i]}
            snakes[$i]=$pre_snake
            pre_snake=$transition_value
        done
        # eat egg and lay egg
        if [ "${snakes[0]}" == "$egg_x,$egg_y" ] ;then
            snakes[${#snakes[@]}]=$pre_snake
            [ "${#snakes[@]}" -eq "$max_blocks" ] && finish "Congratulations, You WIN !" && return
            lay_egg
            let score++ 
            # when more_difficult=1, current speed = flash_time - score/5* rising_rate > min_flash_time
            if [ $more_difficult -ne 0 ] ;then
                speed_tmp=`printf "%.2f" $(echo "$flash_time - $score / 5 * $rising_rate"|bc)`
                [[ $speed_tmp > $min_flash_time ]] &&  cur_speed=$speed_tmp || cur_speed=$min_flash_time
            fi
        fi
        # display the snake
        tput cup ${snakes[0]##*,} ${snakes[0]%%,*}
        echo -n "$snake_head"
        for i in `seq 1 $[${#snakes[@]}-1]`;do
            tput cup ${snakes[$i]##*,} ${snakes[$i]%%,*}
            echo -n "$snake"
        done
        sleep $cur_speed
    done
}

function input()
{
    input_direction=$begin_direction
    while (( 1 ));do
        read -sn 1 dir
        [ -f $flag_file -a ! -f $finish_flag ] && continue
        case $dir in 
            W|w)
            [ "$input_direction" == up -o "$input_direction" == down ] && continue
            input_direction=up
            echo "$input_direction" > $flag_file
            ;;

            A|a)
            [ "$input_direction" == left -o "$input_direction" == right ] && continue
            input_direction=left
            echo "$input_direction" > $flag_file
            ;;

            S|s)
            [ "$input_direction" == up -o "$input_direction" == down ] && continue
            input_direction=down
            echo "$input_direction" > $flag_file
            ;;

            D|d)
            [ "$input_direction" == left -o "$input_direction" == right ] && continue
            input_direction=right
            echo "$input_direction" > $flag_file
            ;;

            # pause
            P|p)
            echo "pause" > $flag_file
            ;;

            # exit
            Q|q)
            kill -- -$$
            ;;

            # retry
            C|c)
            [ ! -f $finish_flag ] && continue
            input_direction=$begin_direction
            begin &
            ;;

            # press any key to exit the pause
            *)
            echo "$dir" > $flag_file
            ;;

        esac
    done
}

function begin()
{
    [ -e $flag_file ] && rm $flag_file
    [ -e $finish_flag ] && rm $finish_flag
    cur_speed=$flash_time
    top_border=$border
    second_border=$border
    for ((i=0;i < length;i++));do
        top_border="$top_border$border"
        second_border="$second_border$space"
    done
    top_border="$top_border$border"
    second_border="$second_border$border"
    # hide cursor
    tput civis
    clear
    # draw border
    echo $top_border
    for ((i=0;i < height;i++));do
        echo "$second_border"
    done
    echo $top_border
    game
} 

begin&
input
