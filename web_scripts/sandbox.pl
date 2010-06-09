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
	
# Create Jquery tabbed box with 2 tabs
	print <<EOF;
<script type="text/javascript">

	\$(
		function()
		{
			\$("#tabs").tabs();
		}
	);
</script>


<div id="tabs">
	<ul>
		<li><a href="#tabs-1">Search</a></li>
		<li><a href="#tabs-2">Browse/Filter</a></li>
	</ul>
	<div id="tabs-1">	
		<p>Search Box here....</p>
	</div>
	<div id="tabs-2">

EOF
# In the second tab: add dropdown filter/search arrow
# menu


	print <<EOF;
	<form id="filtercategories" onSubmit="return onImportFilters();" >
	<input type='button' value="Select/Deselect All" onclick="checkAll('filtercategories');">
	<!-- Send selected filter categories to display pannel via ajax -->
	<input type='submit' name='import' value='Import'">
EOF

	my $data = {
		'Species' 	=> ['Human', 'Mouse', 'Platypus'],
		'Kind'		=> ['Coexpression', 'Annotation']
	};

	htmlHelper::beginSection("Species", FALSE);
	foreach (@{$data->{'Species'}}) { 
		print "<input type=checkbox id=\"Species:$_\" name=\"$_\">$_<br>\n";
	}
	htmlHelper::endSection("Species");

	htmlHelper::beginSection("Kind", FALSE);
	my @species = qw(Coexpression Mouse Platypus);
	foreach (@{$data->{'Kind'}}) { 
		print "<input type=checkbox id=\"Kind:$_\" name=\"$_\">$_<br>\n";
	}
	htmlHelper::endSection("Kind");

	print <<EOF;
	</form>
	</div> <!-- tabs-2 -->
</div>  <!-- tabs -->
<!-- end of tabs -->
EOF
	
}

