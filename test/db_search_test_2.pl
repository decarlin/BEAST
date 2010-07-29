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


my @merged = $treeBuilder->searchOnSetDescriptions('reproduction');

my $json_text;
$json_text = $merged[0]->serialize();
#print Data::Dumper->Dump([$top_level_nodes[0]]);
print "encoded:\n";
print "$json_text:\n";
my $newset = Set->new($json_text);
#print Data::Dumper->Dump([$newset]);
my $new_text =  $newset->serialize();
print "\n";
print $new_text;


$beastDB->disconnectDB();

