#!/usr/bin/perl -w
#################################
#######     index.pl       #######
#################################

use strict;
use warnings;
use CGI;
use CGI::Carp qw(fatalsToBrowser);	#the die could be used safely in web envrionment
use Data::Dumper;
use lib "/projects/sysbio/map/Projects/BEAST/perllib";
use utils;		  #contains useful, simple functions such as trim, max, min, and log_base
use htmlHelper;

# don't have permission to install, so this has to be packaged
use CGI::Session;

# global variable
our $cgi = new CGI();

#my $sid = $cgi->cookie("CGISESSID") || undef;
#### restore their session, or create a new one if it doesn't exist yet
#our $session = new CGI::Session(undef, $sid, {Directory=>'/tmp'});
#$session->expire('+1h');
##
#### save sid in the users cookie
#our $cookie = $cgi->cookie(CGISESSID => $session->id);
#print $cgi->header( -cookie=>$cookie );
#
#our @sets;


#main
{
	print $cgi->header();

	my $fh = $cgi->upload('my_BEAST_upload_file');
#	my $txt = $cgi->param('importtext');
#	my $tmp = ref($fh);
	
	print '<br/>==============<br/>';
	print "http_request parameters:<br/>";
	my @names = $cgi->param;
	foreach my $name (@names)
	{
		print "$name:$cgi->param($name)<br/>";
	}
	print '<br/>==============<br/>';
	print "read and echo file:<br/>";
	while(my $line = <$fh>)
	{
		print $line."<br/>";
	}
#	print $tmp;;
	print '<br/>==============<br/>';


}# end main

