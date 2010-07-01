#!/usr/local/bin/perl

use strict;
use warnings;

use BEAST::BeastDB;

our $beastDB = BeastDB->new;
$beastDB->connectDB();

my @results = $beastDB->getParentsForSet(114005);
my $meta = $results[0];
foreach (@results) {
	print $_."\n";
}
my @results2 = $beastDB->getParentsForMeta($meta);
foreach (@results2) {
	print $_."\n";
}

$beastDB->disconnectDB();
