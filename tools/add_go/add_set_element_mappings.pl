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

# create the meta mappings 
open (MAPPINGS, $mappings_file) || die "can't open $mappings_file!";
while (<MAPPINGS>) {
	my $line = $_;
	chomp ($line);
	my ($set_name, $entity_key, $null) = split(/\t/, $line ); 

	print "Adding set-entity relation: $set_name:$entity_key\n";

	my $id_set = $sets->{$set_name};
	my $id_entity = $elements->{$entity_key};
	if ($id_set eq "") {
		print "no entry for set: $set_name, skipping relation...\n";
		print FAILED "$set_name:$entity_name\n";
		next;
	} elsif ($id_entity eq "") {
		print "no entry for entity: $entity_key, skipping relation...\n";
		print FAILED "$set_name:$entity_key\n";
		next;
	}

	if ($importer->existsSetEntityRel($id_set, $id_entity) > 0) {
		print "set already exists in DB!: $name\n";
	} else {
		print "no relation in DB, adding...\n";
		$importer->insertSetEntityRel($id_set, $id_entity, "NULL");
		unless ($importer->existsSetEntityRel($id_set, $id_entity) > 0) {
			print "Failed to add!\n";	
		}
	}
	print "done\n";
}
close (MAPPINGS);

$importer->disconnectDB();
