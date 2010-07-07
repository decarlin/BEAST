#!/usr/local/bin/perl

use strict;
use warnings;

use lib "/projects/sysbio/map/Projects/BEAST/perllib";

use BEAST::BeastDB;
use BEAST::Search;
use BEAST::MySets;
use Data::Dumper;


my $setid = 114005;
our $beastDB = BeastDB->new;
$beastDB->connectDB();

print "Testing parents for set: $setid\n";
my @results = $beastDB->getSetNameExtIdFromID($setid);
print @results;

my @results = $beastDB->getParentsForSet($setid);
my $meta = $results[0];
foreach (@results) {
	print $_."\n";
}
print "Testing parents for meta: $meta\n";
my @results2 = $beastDB->getParentsForMeta($meta);
foreach (@results2) {
	print $_."\n";
}


my $treeBuilder = Search->new($beastDB);

my @top_level_nodes = $treeBuilder->findParentsForSet($setid);
print "<html><body>\n";
MySets::displaySets("test", @top_level_nodes);
print "</body></html>\n";

my @array = $treeBuilder->findParentsForSetByExtID("mouse:GO:0000004");
print Data::Dumper->Dump([@array]);
$beastDB->disconnectDB();

