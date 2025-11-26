#!/usr/bin/env bash
set -euo pipefail

show_system_info() {
    echo "=== Basic System Information ==="
    echo "Hostname: $(hostname)"

    if [[ -r /etc/os-release ]]; then
        # shellcheck disable=SC1091
        . /etc/os-release
        echo "OS: $PRETTY_NAME"
    else
        echo "OS: $(uname -srm)"
    fi

    echo
    echo "Uptime:"
    uptime
    echo
}

show_disk_usage() {
    echo "=== Disk Usage (df -h, excluding tmpfs/devtmpfs) ==="
    # Keep header (NR==1), filter out tmpfs and devtmpfs
    df -h | awk 'NR==1 || ($1 !~ /tmpfs/ && $1 !~ /devtmpfs/)'
    echo
}

show_top_mem() {
    echo "=== Top 5 Memory-Consuming Processes ==="
    # Header + top 5 processes
    ps aux --sort=-%mem | head -n 6
    echo
}

show_user_info() {
    echo "=== Current User Session Info ==="
    echo "User:   $(whoami)"
    echo "UID:    $(id -u)"
    echo "Groups: $(id -Gn)"
    echo "Home:   $HOME"
    echo "Shell:  $SHELL"
    echo
}

generate_full_report() {
    local timestamp report
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    report="sysreport-$(date '+%Y-%m-%d_%H-%M-%S').txt"

    {
        echo "System Report - $timestamp"
        echo "======================================="
        echo

        echo "1. Basic System Information"
        echo "---------------------------------------"
        show_system_info

        echo "2. Disk Usage Report"
        echo "---------------------------------------"
        show_disk_usage

        echo "3. Top 5 Memory-Consuming Processes"
        echo "---------------------------------------"
        show_top_mem

        echo "4. Current User Session Info"
        echo "---------------------------------------"
        show_user_info
    } > "$report"

    echo "Full report generated: $report"
}

pause() {
    read -rp "Press Enter to return to the menu..." _
}

while true; do
    clear
    echo "============== System Report Menu =============="
    echo "1) Show basic system info"
    echo "2) Show disk usage report"
    echo "3) Show top 5 memory-consuming processes"
    echo "4) Show current user session info"
    echo "5) Generate full report to file"
    echo "6) Exit"
    echo "================================================"
    echo
    read -rp "Choose an option [1-6]: " choice

    case "$choice" in
        1)
            clear
            show_system_info
            pause
            ;;
        2)
            clear
            show_disk_usage
            pause
            ;;
        3)
            clear
            show_top_mem
            pause
            ;;
        4)
            clear
            show_user_info
            pause
            ;;
        5)
            clear
            generate_full_report
            pause
            ;;
        6)
            echo "Goodbye!"
            exit 0
            ;;
        *)
            echo "Invalid choice: '$choice'" >&2
            sleep 1
            ;;
    esac
done
