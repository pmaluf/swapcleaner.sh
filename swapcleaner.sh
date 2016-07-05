#!/bin/bash
# swapcleaner.sh - Limpa a area de swap automaticamente
# Autor: Paulo Victor - paulo.maluf@oi.net.br - 01/2014
#
# Alteracoes:
#
# Data       Autor               Descricao
# ---------- ------------------- ----------------------------------------------------
#  6/2014    Paulo Victor        Adicionado a funcao trap
#====================================================================================

# Variaveis
SWAPON="/sbin/swapon"
SWAPOFF="/sbin/swapoff"
SYNC="/bin/sync"

log(){
 MSG=$1
 COLOR=$2
 if [ "${COLOR}." == "blue." ]
  then
     echo -ne "\e[34;1m${MSG}\e[m"
  elif [ "${COLOR}." == "yellow." ]
    then
      echo -ne "\e[33;1m${MSG}\e[m"
  elif [ "${COLOR}." == "green." ]
    then
      echo -ne "\e[32;1m${MSG}\e[m"
  elif [ "${COLOR}." == "red." ]
    then
      echo -ne "\e[31;1m${MSG}\e[m"
  else
    echo -ne "${MSG}"
 fi
}

trap "{
  log '\n*** CAUTION *** Do not quit with swapoff running!!\n' red
  log 'If you do it, please execute the script again!!\n' red
}" SIGINT

get_mem_usage(){
 MEM_TOTAL=`cat /proc/meminfo | grep MemTotal | awk '{ print $2}'`
 MEM_FREE=`cat /proc/meminfo | grep MemFree | awk '{ print $2}'`
 MEM_USED=$((${MEM_TOTAL}-${MEM_FREE}))
 MEM_PCT_USED=$((${MEM_USED}*100/${MEM_TOTAL}))

 BUFFER=`cat /proc/meminfo | grep Buffers | awk '{ print $2}'`
 CACHE=`cat /proc/meminfo | grep Buffers | awk '{ print $2}'`

 SWAP_TOTAL=`cat /proc/meminfo | grep SwapTotal | awk '{ print $2}'`
 SWAP_FREE=`cat /proc/meminfo | grep SwapFree | awk '{ print $2}'`
 SWAP_USED=$((${SWAP_TOTAL}-${SWAP_FREE}))
 SWAP_PCT_USED=$((${SWAP_USED}*100/${SWAP_TOTAL}))
}

spinner() {
 local pid=$1
 local delay=0.75
 local spinstr='|/-\'
 while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
     local temp=${spinstr#?}
     printf " [%c]  " "$spinstr"
     local spinstr=$temp${spinstr%"$temp"}
     sleep $delay
     printf "\b\b\b\b\b\b"
 done
 printf "    \b\b\b\b"
}

show_mem_usage(){
 log "Memory total: $((${MEM_TOTAL}/1024))Mb "
 log "Memory free: $((${MEM_FREE}/1024))Mb "
 log "Used: $MEM_PCT_USED%\n"
 log "Swap total: ${SWAP_TOTAL} "
 log "Swap free: ${SWAP_FREE} "
 log "Used: $SWAP_PCT_USED%\n"
}

swapclean(){
 ( ${SYNC} ; ${SWAPOFF} -a ) &
 log "swapoff is running, please wait..." yellow
 spinner $!
 ${SWAPON} -a
 get_mem_usage
 if [ ${SWAP_USED} -gt 0 ]
  then
    log "Swap area isn't cleared try again later!\n" red
    show_mem_usage
    exit 1
  else
    log "Swap area cleaner successfully!\n" green
    show_mem_usage
 fi
}

drop_caches(){
 ${SYNC}
 echo 3 > /proc/sys/vm/drop_caches
 log "Cache cleared.\n"
}

#####################
# BEGIN             #
#####################
get_mem_usage

if [ ${SWAP_USED} -gt 0 ]
 then
   if [ ${MEM_FREE} -gt ${SWAP_USED} ]
    then
      show_mem_usage
      swapclean
    else
      log "There's no space avaiable for swappoff.\n"
      log "Trying to clear RAM cache area.\n"
      drop_caches
      get_mem_usage
      if [ ${MEM_FREE} -gt ${SWAP_USED} ]
       then
         swapclean
         show_mem_usage
       else
         log "Sorry, could not clear swap area.! Try again...\n" red
      fi
   fi
 else
  log "Swap is OK! No SWAPOFF needed.\n" green
fi
