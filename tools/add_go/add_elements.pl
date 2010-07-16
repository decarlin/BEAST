#!/usr/local/bin/perl

use lib "/projects/sysbio/map/Projects/BEAST/perllib";

sub usage 
{
	print <<EOF;
##
## Usage:  perl $0 --elements=file1 
##
EOF
}


use BEAST::BeastDB;

use Getopt::Long;

my $elements_file = '';
GetOptions("elements=s" => \$elements_file);

die &usage() unless (-f $elements_file);

our $importer = BeastDB->new('dev');
$importer->connectDB();



open (ELS,$elements_file) || die "can't open $sets_file!";
while (<ELS>) {
	chomp($_);
	my ($name, $desc, $entity_key, $keyspace) = split (/\t/, $_ );

	my $id;
	if (($id = $importer->existsEntity($entity_key, $keyspace)) > 0) {
		print "set already exists in DB!: $name\n";
	} else {
		#$id = $importer->insertEntity($name, $desc, $entity_key, $keyspace);
		if ($id =~ /\d+/) {
			print "Added entity $name \n";
		} else {
			print "Failed to add set $name!\n";
		}
	}
}
close (ELS);

$importer->disconnectDB();
