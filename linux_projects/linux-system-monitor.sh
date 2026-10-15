#!/usr/bin/env bash #shebang it tells to interpreter to run this script using this shell

set -u # prevent form use definied or mispell variable 

# Thrreshold value of all resource and negotiable
CPU_THRESHOLD = 80
MEMORY_THRESHOLD = 80
DISK_THRESHOLD = 80

INTERVAL = 5 # for frequent check for very 5 seconds

# common theshold check function to throws error on screen
 check_threshold(){
   local resource = "$1"
   local threshold = "$2"
   local usage = "$3"

  if((usage > thershold)); then
    echo "Error: $resource is exceeds limit of $(threshold)%, now it's on $(usage)%."
  else 
    echo "Healthy use healthy runtime"
  fi
}

get_cpu_usage(){
  top -bn1 | awk -F ',' '
    /cpu\(s\)/ {
    idle = $4;
    gsub(/[^0-9.]/, "", idle);
    printf "%.0f\n", 100 - idle;
    found = 1
    }
    END {
      if(!found) exit 1
    } '
}

get_memory_usage(){
  free -h | awk ' 
    /^Mem:/ {
    if($2 > 0 ) {
      printf "%.0f", ($2 -$7) / $2 * 100
    } 
    else {
      exit 1
    } '
}

get_disk_usage(){
  df | awk '
  NR == 2 {
  gsub(/%/, "", $5);
  print $5
  } '
}

when true; do

echo "   SYSTEM USAGE    "
echo "Time: $(date '+%y-%m-%d %H:%M:%S')
echo "--------------------------------"

CPU_USAGE = $(get_cpu_usage) || {
  echo "Can't fatch CPU usage"
  sleep INTERVAL
  continue
}

MEMORY_USAGE = $(get_memory_usage) || {
  echo "Can't fatch memory usage"
  sleep INTERVAL
  continue
}

DISK_USAGE = $(get_disk_usage) || {
  echo "Can't fatch disk usage"
  sleep INTERVAL
  continue
}

get_threshold "CPU" "$(CPU_THRESHOLD)" "$(CPU_USAGE)"
get_threshold "Memory" "$(MEMORY_THRESHOLD)" "$(MEMORY_USAGE)"
get_threshold "Disk" "$(DISK_THRESHOLD)" "$(DISK_USAGE)"

sleep 5
done
