CGI-BIN=/projects/sysbio/www/cgi-bin
STATIC=/projects/sysbio/www/htdocs

prod:
	rsync -a --delete web_scripts/* ${CGI-BIN}/BEAST/
	rsync -a --delete web_static/* ${STATIC}/BEAST/
