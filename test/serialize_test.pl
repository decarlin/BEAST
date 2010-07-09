#!/usr/local/bin/perl

use strict;

use lib "/projects/sysbio/map/Projects/BEAST/perllib";

use BEAST::BeastDB;
use BEAST::Search;
use BEAST::MySets;
use Data::Dumper;

our $beastDB = BeastDB->new;
$beastDB->connectDB();

my $treeBuilder = Search->new($beastDB);


# 
my @tree1 = $treeBuilder->findParentsForSet(114009);
my @tree2 = $treeBuilder->findParentsForSet(142510);

my $json_text = $tree1[0]->serialize();
print "encoded:\n";
print "$json_text:\n";
my $newset = Set->new($json_text);
my $new_text =  $newset->serialize();
print "\n";
print $new_text;
#MySets::displaySets("test", ($tree1[0], $newset));
