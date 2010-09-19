CGI-BIN=/projects/sysbio/www/cgi-bin
MAP=/projects/sysbio/map/Projects

sysbio:
	cp -R web_scripts/* ${CGI-BIN}/BEAST/
	cp -R perllib/* ${MAP}/BEAST/perllib
	cp -R web_static/* ${MAP}/BEAST/web_static
	
	cd javalib/src/heatmap && make jar
	cp -R javalib/src/heatmap/heatmap.jar ${MAP}/BEAST/javalib
	cp -R javalib/src/heatmap/heatmap.jar ${CGI-BIN}/BEAST/bin


