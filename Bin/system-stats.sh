#!/bin/bash

# A Bash script to monitor system stats and output them in JSON format.
# This script is a conversion of ZigStat

# --- Configuration ---
# Default sleep duration in seconds. Can be overridden by the first argument.
SLEEP_DURATION=3

# --- Argument Parsing ---
# Check if a command-line argument is provided for the sleep duration.
if [[ -n "$1" ]]; then
  # Basic validation to ensure the argument is a number (integer or float).
  if [[ "$1" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
    SLEEP_DURATION=$1
  else
    # Output to stderr if the format is invalid.
    echo "Warning: Invalid duration format '$1'. Using default of ${SLEEP_DURATION}s." >&2
  fi
fi

# --- Global Cache Variables ---
# These variables will store the discovered CPU temperature sensor path and type
# to avoid searching for it on every loop iteration.
TEMP_SENSOR_PATH=""
TEMP_SENSOR_TYPE=""

# --- Data Collection Functions ---

#
# Gets memory usage in GB, MB, and as a percentage.
#
get_memory_info() {
  awk '
    /MemTotal/ {total=$2}
    /MemAvailable/ {available=$2}
    END {
      if (total > 0) {
        usage_kb = total - available
        usage_gb = usage_kb / 1000000
        usage_percent = (usage_kb / total) * 100
        printf "%.1f %.0f\n", usage_gb, usage_percent
      } else {
        # Fallback if /proc/meminfo is unreadable or empty.
        print "0.0 0 0"
      }
    }
  ' /proc/meminfo
}

#
# Gets the usage percentage of the root filesystem ("/").
#
get_disk_usage() {
  # df gets disk usage. --output=pcent shows only the percentage for the root path.
  # tail -1 gets the data line, and tr removes the '%' sign and whitespace.
  df --output=pcent / | tail -1 | tr -d ' %'
}

#
# Calculates current CPU usage over a short interval.
#
get_cpu_usage() {
  # Read all 10 CPU time fields to prevent errors on newer kernels.
  read -r cpu prev_user prev_nice prev_system prev_idle prev_iowait prev_irq prev_softirq prev_steal prev_guest prev_guest_nice < /proc/stat
  
  # Calculate previous total and idle times.
  local prev_total_idle=$((prev_idle + prev_iowait))
  local prev_total=$((prev_user + prev_nice + prev_system + prev_idle + prev_iowait + prev_irq + prev_softirq + prev_steal + prev_guest + prev_guest_nice))
  
  # Wait for a short period.
  sleep 0.05
  
  # Read all 10 CPU time fields again for the second measurement.
  read -r cpu user nice system idle iowait irq softirq steal guest guest_nice < /proc/stat
  
  # Calculate new total and idle times.
  local total_idle=$((idle + iowait))
  local total=$((user + nice + system + idle + iowait + irq + softirq + steal + guest + guest_nice))
  
  # Add a check to prevent division by zero if total hasn't changed.
  if (( total <= prev_total )); then
      echo "0.0"
      return
  fi

  # Calculate the difference over the interval.
  local diff_total=$((total - prev_total))
  local diff_idle=$((total_idle - prev_total_idle))

  # Use awk for floating-point calculation and print the percentage.
  awk -v total="$diff_total" -v idle="$diff_idle" '
    BEGIN {
      if (total > 0) {
        # Formula: 100 * (Total - Idle) / Total
        usage = 100 * (total - idle) / total
        printf "%.1f\n", usage
      } else {
        print "0.0"
      }
    }'
}

#
# Finds and returns the CPU temperature in degrees Celsius.
# Caches the sensor path for efficiency.
#
get_cpu_temp() {
  # If the sensor path hasn't been found yet, search for it.
  if [[ -z "$TEMP_SENSOR_PATH" ]]; then
    for dir in /sys/class/hwmon/hwmon*; do
      # Check if the 'name' file exists and read it.
      if [[ -f "$dir/name" ]]; then
        local name
        name=$(<"$dir/name")
        # Check for supported sensor types (matches Zig code).
        if [[ "$name" == "coretemp" || "$name" == "k10temp" ]]; then
          TEMP_SENSOR_PATH=$dir
          TEMP_SENSOR_TYPE=$name
          break # Found it, no need to keep searching.
        fi
      fi
    done
  fi

  # If after searching no sensor was found, return 0.
  if [[ -z "$TEMP_SENSOR_PATH" ]]; then
    echo 0
    return
  fi

  # --- Get temp based on sensor type ---
  if [[ "$TEMP_SENSOR_TYPE" == "coretemp" ]]; then
    # For Intel 'coretemp', average all core temperatures.
    # find gets all temp inputs, cat reads them, and awk calculates the average.
    # The value is in millidegrees Celsius, so we divide by 1000.
    find "$TEMP_SENSOR_PATH" -type f -name 'temp*_input' -print0 | xargs -0 cat | awk '
      { total += $1; count++ }
      END {
        if (count > 0) print int(total / count / 1000);
        else print 0;
      }'

  elif [[ "$TEMP_SENSOR_TYPE" == "k10temp" ]]; then
    # For AMD 'k10temp', find the 'Tctl' sensor, which is the control temperature.
    local tctl_input=""
    for label_file in "$TEMP_SENSOR_PATH"/temp*_label; do
      if [[ -f "$label_file" ]] && [[ $(<"$label_file") == "Tctl" ]]; then
        # The input file has the same name but with '_input' instead of '_label'.
        tctl_input="${label_file%_label}_input"
        break
      fi
    done
    
    if [[ -f "$tctl_input" ]]; then
      # Read the temperature and convert from millidegrees to degrees.
      echo "$(( $(<"$tctl_input") / 1000 ))"
    else
      echo 0 # Fallback
    fi
  else
    echo 0 # Should not happen if cache logic is correct.
  fi
}


# --- Main Loop ---
# This loop runs indefinitely, gathering and printing stats.
while true; do
  # Call the functions to gather all the data.
  # get_memory_info
  read -r mem_gb mem_per <<< "$(get_memory_info)"
  
  # Command substitution captures the single output from the other functions.
  disk_per=$(get_disk_usage)
  cpu_usage=$(get_cpu_usage)
  cpu_temp=$(get_cpu_temp)

  # Use printf to format the final JSON output string, adding the mem_mb key.
  printf '{"cpu": "%s", "cputemp": "%s", "memgb":"%s", "memper": "%s", "diskper": "%s"}\n' \
    "$cpu_usage" \
    "$cpu_temp" \
    "$mem_gb" \
    "$mem_per" \
    "$disk_per"

  # Wait for the specified duration before the next update.
  sleep "$SLEEP_DURATION"
done