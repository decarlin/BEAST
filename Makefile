CGI-BIN=/projects/sysbio/www/cgi-bin
STATIC=/projects/sysbio/www/htdocs
MAP=/projects/sysbio/map/Projects

prod:
	rsync -rlm --delete web_scripts/* ${CGI-BIN}/BEAST/
	rsync -rlm --delete perllib/* ${MAP}/BEAST/perllib
	rsync -rlm --delete web_static/* ${STATIC}/BEAST/
