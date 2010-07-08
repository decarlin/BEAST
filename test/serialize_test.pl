#!/usr/local/bin/perl

use strict;
use warnings;

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

my $tree1str = $tree1[0]->serialize();
my $tree2str = $tree2[0]->serialize();
my @lines = ($tree1str, $tree2str);

my @parsedSets = Set::parseSetLines(@lines);

print $parsedSets[0]->serialize();
