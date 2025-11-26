#!/usr/bin/env bash
set -euo pipefail

usage() {
    cat <<EOF
Usage: $0 SOURCE_DIR DEST_DIR

Create a compressed backup of SOURCE_DIR into DEST_DIR.
Keeps only the latest 5 backups in DEST_DIR.

Options:
  -h, --help    Show this help message.

Example:
  $0 /home/student/project /home/student/backups
EOF
}

if [[ $# -ge 1 && ( "$1" == "-h" || "$1" == "--help" ) ]]; then
    usage
    exit 0
fi

if [[ $# -ne 2 ]]; then
    echo "Error: expected 2 arguments, got $#." >&2
    usage
    exit 1
fi

src_dir=$1
dest_dir=$2

if [[ ! -d "$src_dir" ]]; then
    echo "Error: source directory '$src_dir' does not exist or is not a directory." >&2
    exit 1
fi

if [[ ! -d "$dest_dir" ]]; then
    echo "Destination directory '$dest_dir' does not exist. Creating"
    mkdir -p "$dest_dir"
fi

timestamp=$(date '+%Y-%m-%d_%H-%M-%S')
archive="${dest_dir}/backup-${timestamp}.tar.gz"

echo "Creating backup of '$src_dir' at '$archive'..."

src_parent=$(dirname "$src_dir")
src_base=$(basename "$src_dir")

status=0
if tar -czf "$archive" -C "$src_parent" "$src_base"; then
    echo "Backup created successfully."
else
    status=$?
    echo "Backup failed with status $status." >&2
fi

# Get backup size if the file exists
if [[ -f "$archive" ]]; then
    size=$(du -h "$archive" | cut -f1)
else
    size="N/A"
fi


logfile="${dest_dir}/backup.log"
{
    printf '%s | src=%s | dest=%s | status=%s | size=%s\n' \
        "$(date '+%Y-%m-%d %H:%M:%S')" \
        "$src_dir" \
        "$archive" \
        "$status" \
        "$size"
} >> "$logfile"

echo "Archive size: $size"
echo "Log updated at: $logfile"

backups=( "${dest_dir}"/backup-*.tar.gz )

if [[ -e "${backups[0]}" ]]; then
    count=${#backups[@]}
    if (( count > 5 )); then
        echo "Rotating backups"
        ls -1t "${dest_dir}"/backup-*.tar.gz | tail -n +6 | xargs -r rm --
    fi
fi

exit "$status"
