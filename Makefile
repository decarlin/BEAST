SYSBIO_CGI-BIN=/projects/sysbio/www/cgi-bin
SYSBIO_MAP=/projects/sysbio/map/Projects

HTDOCS=/var/www/html
CGI_BIN=/var/www/cgi-bin
INSTALL_DIR=/projects/sysbio/beast

sysbio:
	# For supported sysbio machines
	cp -R web_scripts/* ${SYSBIO_CGI-BIN}/BEAST/
	cp -R perllib/* ${SYSBIO_MAP}/BEAST/perllib
	cp -R web_static/* ${SYSBIO_MAP}/BEAST/web_static
	
	cd javalib/src/heatmap && make jar
	cp -R javalib/src/heatmap/heatmap.jar ${SYSBIO_CGI-BIN}/BEAST/bin

soe:
	# For beast.soe.ucsc.edu:	
	mkdir -p ${CGI_BIN}/BEAST/bin
	mkdir -p ${HTDOCS}/BEAST/web_static
	
	cp -R web_scripts/* ${CGI_BIN}/BEAST/
	cp -R perllib/* ${INSTALL_DIR}/perllib
	cp -R web_static/* ${HTDOCS}/BEAST
	
	cd javalib/src/heatmap && make jar
	cp -R javalib/src/heatmap/heatmap.jar ${INSTALL_DIR}/bin
	
	chown -R :sysbio ${CGI_BIN}/BEAST/
	chown -R :sysbio ${HTDOCS}/BEAST/
	chown -R :sysbio ${INSTALL_DIR}/perllib/*
