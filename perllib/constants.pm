#!/usr/bin/perl -w
#Author:            Sam Boyarsky (xenicson@gmail.com)
#Create Date:       06/29/2010
#Last Edit Date:    06/29/2010


#at some point this should be turned into a perl object rather than just a module.

package constants;

use strict;
use warnings;
use English;

our @ISA        = qw(Exporter);
our @EXPORT     = qw(	TEMP_DIR
						WEB_STATIC_DIR
						WEB_SCRIPT_DIR
						DEBUG);
our @EXPORT_OK  = qw();
our $VERSION    = 1.0;


use constant TEMP_DIR => "/projects/sysbio/map/Papers/MetaTrans/perl/Data";
use constant WEB_STATIC_DIR => "/projects/sysbio/map/Projects/BEAST/web_static";
use constant WEB_SCRIPT_DIR => "/projects/sysbio/map/Projects/BEAST/web_scripts";
use constant DEBUG => 1;

    
return 1;

