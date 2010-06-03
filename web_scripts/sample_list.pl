#!/usr/bin/perl -w
#################################
#######   sample_list.pl  #######
#################################

use strict;
use warnings;
use CGI;
use CGI::Carp qw(fatalsToBrowser);	#the die could be used safely in web envrionment
use lib "/cse/grads/samb/bin";
use utils;		  #contains useful, simple functions such as trim, max, min, and log_base
use metatransDBHelper;
use l_htmlHelper;

my $input = new CGI();
my $dbh = getDBHandle();
my $results;


#main
{
	print $input->header();
	
	#Get column list from database
	my @columns;
	$results = runSQL("describe samples;", $dbh);
	while (my(@data) = $results->fetchrow_array())
	{
		push(@columns, $data[0]);
	}

	
	#build sql statement
	my $select = "SELECT s.".join(", s.", @columns);	
	my $from = "FROM samples s";
	my $where = "";

	my $sort = $input->param('sort');
	unless(defined get_column_display_name($sort))	#If the column is not defined, blank this out for protection
	{
		$sort = "";
	}
	my $order_by = ($sort eq "") ? "" : "ORDER BY s.$sort DESC";

	my $sql = "$select $from $where $order_by;";
	
	$results = runSQL($sql, $dbh);

	#Print Table Header (translate column names into nice human readable names)
	print "<table border='1px' class='results_table'>\n";
	print "<tr>";
	for(my $i = 0; $i < scalar @columns; $i++)
	{
#		print "<th class='sortable_header_row' OnClick=\"updateDiv('results', 'sample_list.pl', '&sort=$columns[$i]');\">$columns[$i]</th>";	
		print "<th class='sortable_header_row' OnClick=\"updateDiv('results', 'sample_list.pl', '&sort=$columns[$i]');\">".get_column_display_name($columns[$i])."</th>";	
	}
	print "</tr>\n";
	
	#Print data table
	while (my(@data) = $results->fetchrow_array())
	{
		print "<tr onClick=\"showElement('sample', $data[0])\" onMouseOver=\"doTRMouseOver(this)\" onMouseOut=\"doTRMouseOut(this)\" >";
		for(my $i = 0; $i < scalar @data; $i++)
		{
			print "<td>$data[$i]</td>";
		}
		print "</tr>\n";
	}
	print "</table>\n";

	my $timestamp = localtime;
	print "<br/><div class='footer'>$timestamp</div>";

#	printFooter();
}# end main



