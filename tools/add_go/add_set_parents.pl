#!/usr/local/bin/perl

use lib "/projects/sysbio/map/Projects/BEAST/perllib";

sub usage 
{
	print <<EOF;
##
## Usage:  perl $0 --sets=file1
## (insert the sets)
##
EOF
}


use BEAST::BeastDB;

use Getopt::Long;

my $sets_file = '';
GetOptions("sets=s" => \$sets_file);


#die &usage() unless (-f $sets_file);

our $importer = BeastDB->new('dev');
$importer->connectDB();

open (SETS,$sets_file) || die "can't open $sets_file!";
while (<SETS>) {
	my ($external_id, $name) = split (/\t/, $_);
	chomp($name);

	my $set_id;
	my $parent_id;
	unless (($set_id = $importer->existsSet($external_id)) > 0) {
		die "Error: no set found for $external_id;";	
	}

	$parent_ex_id = $external_id;
	$parent_ex_id =~ s/human://;
	$parent_ex_id =~ s/mouse://;
	unless (($parent_id = $importer->existsMeta($parent_ex_id)) > 0) {
		die "Error: no set found for $parent_ex_id;";	
	}
	
	if ($importer->existsSetMetaRel($parent_id, $set_id) > 0) {
		print "relation already exists!\n";
	} else {
		print "no relation between meta's...adding $external_id\n";
		my $id = $importer->insertSetMetaRel($parent_id, $set_id);
		unless ($id =~ /\d+/) { print "failed for $external_id!\n"; }
	}
}
close (SETS);

$importer->disconnectDB();
