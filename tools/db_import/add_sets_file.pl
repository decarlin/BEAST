#!/usr/local/bin/perl


use lib "/projects/sysbio/map/Projects/BEAST/perllib";
use strict;

sub usage 
{
	print <<EOF;
##
## Usage:  perl $0 --sets_file=raw_file 
##
EOF
}

use Getopt::Long;
use Math::BigFloat;
use BEAST::BeastDB;
use BEAST::Loader;

my $sets_file = '';
GetOptions("sets_file=s" => \$sets_file);

die &usage() unless (-f $sets_file);

my $importer = BeastDB->new('test');
$importer->connectDB();


open (SETS_FH, $sets_file) || die;
my @lines = <SETS_FH>;
my @sets = Set::parseSetLines(@lines);
if ($sets[0] == 0) {
	pop @sets;
	print "Failed to parse set lines!\n";
	return;
}

foreach my $set (@sets) {
	my $err_str;
	$set->insertDB($importer,\$err_str);
	print $err_str."\n";
}

$importer->disconnectDB();

