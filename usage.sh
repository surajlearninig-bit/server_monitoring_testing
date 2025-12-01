#!/bin/bash

LOG_FILE="/var/log/server_health.log"
DISK_THRESHOLD=5

# -------------------- Define servers --------------------
# Add all your Node.js server script names here
# Format: "Display Name:ScriptName"
SERVERS=("Automation server Test:server.js" "Automation server 2:server2.js")

# -------------------- CPU Usage --------------------
get_cpu_usage() {
    read cpu user nice system idle iowait irq softirq steal guest < /proc/stat
    total1=$((user + nice + system + idle + iowait + irq + softirq + steal))
    idle1=$idle
    sleep 1
    read cpu user nice system idle iowait irq softirq steal guest < /proc/stat
    total2=$((user + nice + system + idle + iowait + irq + softirq + steal))
    idle2=$idle
    total_diff=$((total2 - total1))
    idle_diff=$((idle2 - idle1))
    usage=$(( (100 * (total_diff - idle_diff)) / total_diff ))
    echo $usage
}

CPU=$(get_cpu_usage)

# -------------------- RAM Usage --------------------
RAM_TOTAL=$(free -m | awk '/Mem:/ {print $2}')
RAM_USED=$(free -m | awk '/Mem:/ {print $3}')
RAM_PERCENT=$(( RAM_USED * 100 / RAM_TOTAL ))

# -------------------- Disk Usage --------------------
DISK_USAGE_PERCENT=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
DISK_INFO=$(df -h / | awk 'NR==2 {print $3 " used out of " $2 " (" $5 ")"}')

# -------------------- Server System Uptime --------------------
SYSTEM_UPTIME=$(uptime -p | sed 's/up //')

# -------------------- Output HTML --------------------
echo "<div style='font-family: monospace; padding: 10px; background-color: #000; color: #0f0;'>"

echo "<h3 style='color:cyan'>SYSTEM STATUS</h3>"
echo "<b>CPU Usage:</b> <span style='color:yellow'>$CPU %</span><br>"
echo "<b>RAM Usage:</b> <span style='color:yellow'>$RAM_USED MB / $RAM_TOTAL MB ($RAM_PERCENT%)</span><br>"
if [ $DISK_USAGE_PERCENT -gt $DISK_THRESHOLD ]; then
    echo "<b>Disk Usage:</b> <span style='color:red'>$DISK_INFO</span><br>"
else
    echo "<b>Disk Usage:</b> <span style='color:green'>$DISK_INFO</span><br>"
fi
echo "<b>Server's System Uptime:</b> <span style='color:cyan'>$SYSTEM_UPTIME</span><br>"

echo "<hr style='border:1px solid cyan'>"
echo "<h3 style='color:blue'>SERVERS STATUS</h3>"

# -------------------- Loop over all servers --------------------
for S in "${SERVERS[@]}"; do
    # Split into display name and script name
    NAME="${S%%:*}"
    SCRIPT="${S##*:}"

    NODE_PIDS=$(pgrep -fx "node .*${SCRIPT}")

    if [ -z "$NODE_PIDS" ]; then
        SERVER_STATUS="<span style='color:red'>DOWN</span>"
        SERVER_UPTIME=""
    else
        SERVER_STATUS="<span style='color:green'>RUNNING</span>"
        EARLIEST_PID=$(echo $NODE_PIDS | awk '{print $1}')
        NODE_UPTIME=$(ps -p $EARLIEST_PID -o etimes=)
        HOURS=$((NODE_UPTIME/3600))
        MINUTES=$(( (NODE_UPTIME%3600)/60 ))
        SECONDS=$((NODE_UPTIME%60))
        SERVER_UPTIME="<span style='color:green'>UP since: ${HOURS}h ${MINUTES}m ${SECONDS}s</span>"
    fi

    echo "<b>$NAME:</b> $SERVER_STATUS<br>"
    [ -n "$SERVER_UPTIME" ] && echo "$SERVER_UPTIME<br>"
done

echo "</div>"

# -------------------- Append to log --------------------
{
echo -n "[$(date)] CPU: $CPU %, RAM: $RAM_USED/$RAM_TOTAL MB ($RAM_PERCENT%), Disk: $DISK_INFO"
for S in "${SERVERS[@]}"; do
    NAME="${S%%:*}"
    SCRIPT="${S##*:}"
    NODE_PIDS=$(pgrep -fx "node .*${SCRIPT}")
    if [ -z "$NODE_PIDS" ]; then
        echo -n ", $NAME: DOWN"
    else
        echo -n ", $NAME: RUNNING"
    fi
done
echo ""
} >> $LOG_FILE
