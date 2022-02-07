for i in {1..365}
do
		# define your mount directory
        if [ -s "$PWD/$(date -d "$DATE+$i days" +%Y-%m-%d)" ]; then
				# 2> /dev/null redirects any messages sent to stderr 
				# to /dev/null instead of sending them to the terminal.
                rm -d $(date -d "$DATE+$i days" +%Y-%m-%d) 2> /dev/null
        fi
done &
