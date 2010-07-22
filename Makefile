CGI-BIN=/projects/sysbio/www/cgi-bin
MAP=/projects/sysbio/map/Projects

prod:
	rsync -rlpD --delete web_scripts/* ${CGI-BIN}/BEAST/
	rsync -rlpD --delete perllib/* ${MAP}/BEAST/perllib
	rsync -rlpD --delete web_static/* ${MAP}/BEAST/web_static
