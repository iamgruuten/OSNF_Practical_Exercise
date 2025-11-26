wc -l access.log
grep ' 404 ' access.log | wc -l
grep '"GET ' access.log  | wc -l
grep '"POST ' access.log | wc -l
awk '{print $1}' access.log | sort | uniq -c | sort -nr | head -10
awk '$9 == 500' access.log > status500.log
awk '$9 == 500 {print $7}' access.log | sort | uniq -c | sort -nr
grep '\[.*:12:' access.log | wc -l
