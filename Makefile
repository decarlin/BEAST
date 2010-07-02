CGI-BIN=/projects/sysbio/www/cgi-bin
STATIC=/projects/sysbio/www/htdocs
MAP=/projects/sysbio/map/Projects

prod:
	rsync -a --delete web_scripts/* ${CGI-BIN}/BEAST/
	rsync -a --delete perllib/* ${MAP}/BEAST/perllib
	rsync -a --delete web_static/* ${STATIC}/BEAST/
