CGI-BIN=/projects/sysbio/www/cgi-bin
MAP=/projects/sysbio/map/Projects

prod:
	rsync -rlpgD --delete web_scripts/* ${CGI-BIN}/BEAST/
	rsync -rlpgD --delete perllib/* ${MAP}/BEAST/perllib
	rsync -rlpgD --delete web_static/* ${MAP}/BEAST/web_static
