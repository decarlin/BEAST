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


die &usage() unless (-f $sets_file);

our $importer = BeastDB->new('dev');
$importer->connectDB();

open (SETS,$sets_file) || die "can't open $sets_file!";
while (<SETS>) {
	my ($external_id, $name) = split (/\t/, $_);
	chomp($name);

	my $id = $importer->existsSet($external_id);
	if ($id > 0) {
		print "set already exists in DB!: $name\n";
	} else {
		$id = $importer->insertSet($name, $external_id);
		if ($id =~ /\d+/) {
			print "Added set id:$id for set $name\n";
		} else {
			print "Failed to add set $name!\n";
		}
	}
}
close (SETS);

$importer->disconnectDB();
