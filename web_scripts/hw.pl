#!/usr/bin/perl -w
#################################
#######   sample_list.pl  #######
#################################

use strict;
use warnings;
use CGI;
use CGI::Carp qw(fatalsToBrowser);	#the die could be used safely in web envrionment

my $input = new CGI();

#main
{
	print $input->header();

	my $sort = $input->param('blah');

	print "Hello World<br/>$sort\n";

}# end main



