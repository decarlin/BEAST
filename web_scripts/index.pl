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
use BEAST::CheckBoxTree;
use BEAST::BrowseTab;
use BEAST::ImportTab;
use BEAST::MySets;
use BEAST::Set;
use BEAST::BeastSession;

# global variable
our $cgi = new CGI();

my $sid = $cgi->cookie("CGISESSID") || undef;
### restore their session, or create a new one if it doesn't exist yet
our $session = new CGI::Session(undef, $sid, {Directory=>'/tmp'});
$session->expire('+1h');
#
### save sid in the users cookie
our $cookie = $cgi->cookie(CGISESSID => $session->id);
print $cgi->header( -cookie=>$cookie );

our @sets;

sub doTabbedMenu();
sub doImportTab();
sub doMySets();

my $browseObj;
my $importObj;

#main
{
	#print $cgi->header();

	# debug

	#run some query, get the set of categories	
	#@my $sql = 
	#$results = runSQL($sql, $dbh);

	$browseObj = BrowseTab->new($cgi);
	$importObj = ImportTab->new($cgi);

	if ($cgi->param('browse')) {
		# replace the browse tab to include the search results

		$browseObj->printBrowseTab($session);
	} elsif ($cgi->param('import')) {
		$importObj->printImportTab();
	} elsif ($cgi->param('mysets')) {
		doMySets();
	} else {
		# default; on page creation	
		doTabbedMenu();	
	}

	#my $activetab = $cgi->param('tab');	
	#my $selected = 1;
	#if ($activetab == 'browse') {
	#	$selected = 2;
	#}

}# end main




sub doTabbedMenu()
{
		
# Create Jquery tabbed box with 2 tabs
	print <<EOF;
<script type="text/javascript">

	\$(
		function()
		{
			\$("#tabs").tabs();
			\$("#mysets_tab").tabs();
		}
	);
</script>

<div class="mysets_div" id="mysets_tab">
	<ul>
		<li><a href="#mysets">MySets</a></li>
	</ul>
	<div id="mysets">
EOF
	doMySets();
# mysets
print "</div>";
# surrounding div
print "</div>";

print <<EOF;
<div class="myopstabs_div" id="tabs">
	<ul>
		<li><a href="#import">Import</a></li>
		<li><a href="#browse">Browse</a></li>
		<li><a href="http://sysbio.soe.ucsc.edu/BEAST/admin_pages/admin.html">Admin</a></li>
	</ul>
EOF

	print "<div id=\"import\">";
	$importObj->printImportTab();
	print `hostname -f`;
	print "</div>";

	print "<div id=\"browse\">";
	$browseObj->printBrowseTab();
	print "</div>";

	print "<div id=\"admin\">";
	print "</div>";
print "</div>";
}

sub doMySets()
{

	my $beastDB = BeastDB->new;
	$beastDB->connectDB();
	my $treeBuilder = Search->new($beastDB);
	my @tree1 = $treeBuilder->findParentsForSet(114104);
	#my @tree2 = $treeBuilder->findParentsForSet(114104);
	$beastDB->disconnectDB();

	push @sets, $tree1[0];
	#unless ($tree1[0]->mergeTree($tree2[0]) > 0) {
	#	push @sets, $tree2[0];	
	#}

	if ($cgi->param('browsesets[]')) {
		#my @browseSets = BeastSession::loadBrowseSets($session, $cgi->param('browsesets[]'));
		#print Data::Dumper->Dump([$cgi]);
	}

	print "<form id=\"mysetsform\">";
	if ($cgi->param('checkedelements[]')) {
		my $checked = {};
		my @checked = $cgi->param('checkedelements[]');	
		foreach (@checked) {
			$checked->{$_} = 1;
		}
		MySets::updateActiveElements($checked, \@sets);	
	}
	MySets::displaySets(@sets);


	BeastSession::saveMySets($session, @sets);
	# save sets data in the session

	print "<input type='button' value='Update' onClick=\"return onUpdateMySets(this.form);\"><br>";
	print "</form>";

}

