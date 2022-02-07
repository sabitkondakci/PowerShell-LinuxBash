{ for i in {1..365}; do mkdir $(date -d "$DATE+$i days" +%Y-%m-%d); done; } &
