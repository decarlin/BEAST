#!/usr/local/bin/perl

use strict;
use warnings;

use lib "/projects/sysbio/map/Projects/BEAST/perllib";

use BEAST::BeastDB;
use BEAST::Search;
use BEAST::MySets;
use Data::Dumper;

my @sets = (114005, 114104, 114156, 115200, 115112, 115780, 114110, 116000, 116234, 116367, 117555);
our $beastDB = BeastDB->new;
$beastDB->connectDB();

my $treeBuilder = Search->new($beastDB);


# 
my @tree1 = $treeBuilder->findParentsForSet(114009);
my @tree2 = $treeBuilder->findParentsForSet(142510);

if ($tree1[0]->mergeTree($tree2[0]) > 0) {
	print "Merged Trees: \n";
	print $tree1[0]->serialize();
} else {
	print "Couldn't merge trees:\n";
	print $tree1[0]->serialize();
	print $tree2[0]->serialize();
}

$beastDB->disconnectDB();
exit;

open OUTPUT, ">sets.output";
foreach (@sets) {
	my $set = $_;
	open STDOUT, ">$set.tree" || die "can't open";
	my @top_level_nodes = $treeBuilder->findParentsForSet($set);
	MySets::displaySets("test",@top_level_nodes);
	close STDOUT || die "can't open file";

	open TREE, "$_.tree";
	my @lines = <TREE>;
	foreach (@lines) {
		if ($_ =~ /end (GO:\d+.*) --/) {
			my @pieces = split(/<>/, $1);	
			my $count = 1;
			foreach (@pieces) {
			  foreach (1 .. $count) { print OUTPUT "\t"; }
			  $count++;
			  print OUTPUT $_."\n";
			}
			last;
		}
	}
	`rm $set.tree`;
}
close OUTPUT;

$beastDB->disconnectDB();

