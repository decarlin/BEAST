#!/usr/bin/perl -w
#################################
#######     sandbox.pl       #######
#################################

use strict;
use warnings;
use CGI;
use CGI::Carp qw(fatalsToBrowser);	#the die could be used safely in web envrionment
use lib "/projects/sysbio/map/Projects/BEAST/perllib";
use utils;		  #contains useful, simple functions such as trim, max, min, and log_base
use htmlHelper;

my $input = new CGI();
my $results;

sub doFilterCategories();

#main
{
	print $input->header();
	

	#run some query, get the set of categories	
	#@my $sql = 
	#$results = runSQL($sql, $dbh);

	doFilterCategories();	

	my $timestamp = localtime;
	print "<br><div class='footer'>$timestamp</div>";

#	printFooter();
}# end main




sub doFilterCategories()
{
	
	htmlHelper::beginSection("Species", FALSE);

	my $body = <<EOF;
	<br>Human<br>
	<br>Mouse<br>
	<br>Platypus<br>
EOF
	print $body."\n";
	htmlHelper::endSection("Species");
	
}

