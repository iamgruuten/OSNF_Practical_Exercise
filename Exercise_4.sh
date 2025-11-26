#!/usr/bin/env bash
set -euo pipefail

usage() {
    cat <<EOF
Usage: $0 -d DIR [-p PREFIX] [-s SUFFIX] [-n]

Rename all regular files in DIR by adding PREFIX and/or SUFFIX.
SUFFIX is added before the file extension, if any.

Options:
  -d DIR     Directory containing files to rename (required)
  -p PREFIX  String to add before the base filename (optional)
  -s SUFFIX  String to add before the extension (optional)
  -n         Dry-run (show what would be done, but do not rename)

Examples:
  $0 -d images -p "summer_"
  $0 -d photos -s "_edited"
  $0 -d photos -p "summer_" -s "_edited" -n
EOF
}

dir=""
prefix=""
suffix=""
dry_run=0

# --- Parse options ---

while getopts ":d:p:s:n" opt; do
    case "$opt" in
        d) dir=$OPTARG ;;
        p) prefix=$OPTARG ;;
        s) suffix=$OPTARG ;;
        n) dry_run=1 ;;
        \?)
            echo "Error: unknown option -$OPTARG" >&2
            usage
            exit 1
            ;;
        :)
            echo "Error: option -$OPTARG requires an argument." >&2
            usage
            exit 1
            ;;
    esac
done

if [[ -z "$dir" ]]; then
    echo "Error: -d DIR is required." >&2
    usage
    exit 1
fi

if [[ ! -d "$dir" ]]; then
    echo "Error: '$dir' is not a directory." >&2
    exit 1
fi

shopt -s nullglob

renamed_any=0

for filepath in "$dir"/*; do
    [[ -f "$filepath" ]] || continue

    filename=${filepath##*/}  
    base=$filename
    ext=""

    if [[ "$filename" == *.* ]]; then
        base=${filename%.*}
        ext=${filename##*.}
    fi

    newbase="${prefix}${base}${suffix}"

    if [[ -n "$ext" && "$base" != "$filename" ]]; then
        newname="${newbase}.${ext}"
    else
        newname="$newbase"
    fi

    # If no change, skip
    if [[ "$filename" == "$newname" ]]; then
        continue
    fi

    target="${dir}/${newname}"

    # Avoid overwriting
    if [[ -e "$target" ]]; then
        echo "Skipping '$filename' -> '$newname' (target exists)" >&2
        continue
    fi

    if (( dry_run )); then
        echo "Would rename '$filename' -> '$newname'"
    else
        mv -- "$filepath" "$target"
        echo "Renamed '$filename' -> '$newname'"
    fi

    renamed_any=1
done

if (( ! renamed_any )); then
    echo "No files were renamed in '$dir'."
fi
