find '/home/fox/weblist.txt' | xargs -i \
wget -U 'Mozilla/5.0 (X11; Linux i686) AppleWebKit/537.17 (KHTML, like Gecko) Chrome/24.0.1312.27 Safari/537.17' \
-t 1 --timeout 3 -i {} &
