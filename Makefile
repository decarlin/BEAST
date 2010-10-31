SYSBIO_CGI-BIN=/projects/sysbio/www/cgi-bin
SYSBIO_MAP=/projects/sysbio/map/Projects

HTDOCS=/var/www/html/BEAST
CGI_BIN=/var/www/cgi-bin/BEAST

sysbio:
	# For supported sysbio machines
	cp -R web_scripts/* ${SYSBIO_CGI-BIN}/BEAST/
	cp -R perllib/* ${SYSBIO_MAP}/BEAST/perllib
	cp -R web_static/* ${SYSBIO_MAP}/BEAST/web_static
	
	cd javalib/src/heatmap && make jar
	cp -R javalib/src/heatmap/heatmap.jar ${SYSBIO_CGI-BIN}/BEAST/bin

soe:
	# For beast.soe.ucsc.edu:	
	mkdir -p ${CGI_BIN}/bin
	mkdir -p ${HTDOCS}/perllib
	
	cp -R web_scripts/* ${CGI_BIN}
	cp -R perllib/* ${CGI_BIN}/perllib
	cp -R web_static/* ${HTDOCS}
	
	cd javalib/src/heatmap && make server
	cp -R javalib/src/heatmap/heatmap.jar ${CGI_BIN}/bin
	
	#chown -R :sysbio ${CGI_BIN}
	#chown -R :sysbio ${HTDOCS}
