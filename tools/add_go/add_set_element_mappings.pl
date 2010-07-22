#!/usr/local/bin/perl

use lib "/projects/sysbio/map/Projects/BEAST/perllib";

sub usage 
{
	print <<EOF;
##
## Usage:  perl $0 --mappings=file1 
##
EOF
}


use BEAST::BeastDB;

use Getopt::Long;

my $mappings_file = '';
GetOptions("mappings=s" => \$mappings_file);

die &usage() unless (-f $mappings_file);

our $importer = BeastDB->new('dev');
$importer->connectDB();

our $keyspace;
if ($mappings_file =~ /human/) {
	$keyspace = 1;
} elsif ($mappings_file =~ /mouse/) {
	$keyspace = 2;
} else {
	die;
}

# create the meta mappings 
open (MAPPINGS, $mappings_file) || die "can't open $mappings_file!";
while (<MAPPINGS>) {
	my $line = $_;
	chomp ($line);
	my ($set_name, $entity_key) = split(/\t/, $line ); 

	print "Adding set-entity relation: $set_name:$entity_key\n";

	my $set_id = $importer->existsSet($set_name);
	my $entity_id = $importer->existsEntity($entity_key, $keyspace);

	if ($set_id =~ /\d+/) {
		print "no entry for set: $set_name, skipping relation...\n";
		print FAILED "$set_name:$entity_name\n";
		next;
	} elsif ($entity_id =~ /\d+/) {
		print "no entry for entity: $entity_key, skipping relation...\n";
		print FAILED "$set_name:$entity_key\n";
		next;
	}

	if ($importer->existsSetEntityRel($set_id, $entity_id) > 0) {
		print "set already exists in DB!: $name\n";
	} else {
		print "no relation in DB, adding...\n";
		$importer->insertSetEntityRel($set_id, $entity_id, "NULL");
		unless ($importer->existsSetEntityRel($set_id, $entity_id) > 0) {
			print "Failed to add!\n";	
		}
	}
	print "done\n";
}
close (MAPPINGS);

$importer->disconnectDB();
