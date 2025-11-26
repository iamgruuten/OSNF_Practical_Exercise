whoami          # current user
hostname        # machine name
pwd             # current directory
echo "$SHELL"   # current shell
find . -type f
find . -type d
mkdir -p project/src project/data project/backup
find . -type f -name '*.txt' -not -path './project/*' -exec cp -- '{}' project/data/ \;
find . -type f -name '*.log' -not -path './project/*' -exec mv -- '{}' project/backup/ \;

today=$(date +%F)   # e.g. 2025-11-26

find . -type f -name 'notes.txt' -print0 | \
while IFS= read -r -d '' f; do
    dir=$(dirname "$f")
    mv -- "$f" "$dir/NOTES_${today}.txt"
done

cat > project/README.md << 'EOF'
# Project Directory

This directory contains:
- src/    : source code files
- data/   : input text data copied from lab1_data
- backup/ : log files and other archived material
EOF

history 30 > commands.log
