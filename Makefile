CGI-BIN=/projects/sysbio/www/cgi-bin
MAP=/projects/sysbio/map/Projects

prod:
	rsync -rloD --delete web_scripts/* ${CGI-BIN}/BEAST/
	rsync -rloD --delete perllib/* ${MAP}/BEAST/perllib
	rsync -rloD --delete web_static/* ${MAP}/BEAST/web_static
