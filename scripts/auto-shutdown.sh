#!/bin/bash
# Auto-shutdown when all listed VMs are off or idle for >15min
# Works on Proxmox VE 9

LOG_TAG="auto-shutdown"
THRESHOLD_IDLE_CPU=3.0    # consider VM idle if < 3% CPU
IDLE_MINUTES_REQUIRED=15  # minutes before shutdown
STATE_FILE="/tmp/vm_idle_state.txt"
DRY_RUN=false              # set to true to test without shutdown

log() {
    echo "[$(date '+%F %T')] $1"
    logger -t "$LOG_TAG" "$1"
}

log "=== Running VM idle check ==="

# --- auto-detect all VM IDs ---
VM_IDS=($(qm list | awk 'NR>1 {print $1}'))
if [[ ${#VM_IDS[@]} -eq 0 ]]; then
    log "No VMs found on this host."
    exit 0
fi

log "Detected VM IDs: ${VM_IDS[*]}"
ACTIVE=0

# --- check each VM ---
for ID in "${VM_IDS[@]}"; do
    STATUS=$(qm status "$ID" | awk '{print $2}')
    log "VM $ID status: $STATUS"

    if [[ "$STATUS" == "running" ]]; then
        CPU=$(qm gueststats "$ID" 2>/dev/null | grep "cpu" | awk '{print $2}' | sed 's/%//')
        if [[ -z "$CPU" ]]; then
            log "VM $ID: could not read CPU usage (no guest agent? not logged into VM yet?). Assuming idle."
        else
            CPU=${CPU%.*}
            log "VM $ID: CPU usage $CPU%"
            if (( $(echo "$CPU > $THRESHOLD_IDLE_CPU" | bc -l) )); then
                log "VM $ID: above idle threshold (${THRESHOLD_IDLE_CPU}%). Counting as active."
                ACTIVE=$((ACTIVE+1))
            else
                log "VM $ID: below idle threshold (${THRESHOLD_IDLE_CPU}%). Counting as idle."
            fi
        fi
    else
        log "VM $ID: not running. Counting as idle."
    fi
done

log "Active VM count: $ACTIVE"

# --- Idle timer handling ---
if [[ $ACTIVE -eq 0 ]]; then
    if [[ ! -f "$STATE_FILE" ]]; then
        log "All VMs idle/off — starting idle timer."
        echo "$(date +%s)" > "$STATE_FILE"
    else
        log "All VMs still idle/off — idle timer continues."
    fi
else
    if [[ -f "$STATE_FILE" ]]; then
        log "Some VMs active again — clearing idle timer."
        rm -f "$STATE_FILE"
    else
        log "Some VMs active — no idle timer running."
    fi
fi

# --- Shutdown condition ---
if [[ -f "$STATE_FILE" ]]; then
    LAST_IDLE=$(cat "$STATE_FILE")
    NOW=$(date +%s)
    DIFF=$(( (NOW - LAST_IDLE) / 60 ))
    log "Idle for $DIFF minutes (needs ${IDLE_MINUTES_REQUIRED} to trigger shutdown)."
    if [[ $DIFF -ge $IDLE_MINUTES_REQUIRED ]]; then
        if [[ "$DRY_RUN" == true ]]; then
            log "[DRY-RUN] Would shut down now — skipping actual shutdown."
        else
            log "All VMs idle/off for $DIFF minutes — shutting down host now."
            shutdown -h now
        fi
    fi
else
    log "No idle timer active — system will stay on."
fi

log "=== Check complete ==="
