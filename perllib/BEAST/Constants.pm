#!/usr/bin/perl -w
#Author:            Sam Boyarsky (xenicson@gmail.com)
#Create Date:       06/29/2010
#Last Edit Date:    06/29/2010


#at some point this should be turned into a perl object rather than just a module.

package Constants;

use strict;
use warnings;
use English;

our @ISA        = qw(Exporter);
our @EXPORT     = qw(	TEMP_DIR
						WEB_STATIC_DIR
						WEB_SCRIPT_DIR
						DEBUG
						SET_NAME_DELIM);
our @EXPORT_OK  = qw();
our $VERSION    = 1.0;


use constant TEMP_DIR => "/projects/sysbio/map/Papers/MetaTrans/perl/Data";
use constant JAVA_32_BIN => "/projects/sysbio/apps/i386/jre/jre1.6.0_21/bin/java";
use constant JAVA_64_BIN => "/projects/sysbio/apps/x86_64/jre/jre1.6.0_21/bin/java";
use constant HEATMAP_JAR => "/projects/sysbio/map/Projects/BEAST/javalib/heatmap.jar";
use constant JAVA_ERROR_LOG => "/tmp/beast_java_errlog.txt";
use constant WEB_STATIC_DIR => "/projects/sysbio/map/Projects/BEAST/web_static";
use constant WEB_SCRIPT_DIR => "/projects/sysbio/map/Projects/BEAST/web_scripts";
use constant VIEW_WIDTH => "750";
use constant VIEW_HEIGHT => "580";
use constant DEBUG => 1;
use constant SET_NAME_DELIM => "<>";
    
return 1;
