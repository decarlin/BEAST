CGI-BIN=/projects/sysbio/www/cgi-bin
MAP=/projects/sysbio/map/Projects

prod:
	cp -R web_scripts/* ${CGI-BIN}/BEAST/
	cp -R perllib/* ${MAP}/BEAST/perllib
	cp -R web_static/* ${MAP}/BEAST/web_static
