#!/usr/local/bin/perl

use lib "/projects/sysbio/map/Projects/BEAST/perllib";

sub usage 
{
	print <<EOF;
##
## Usage:  perl $0 --meta_mappings=file1 (meta to meta mapings)
## (insert the meta set mappings)
##
EOF
}


use BEAST::BeastDB;

use Getopt::Long;

my $metas_file = '';
my $meta_mappings = '';
my $debug = '';
GetOptions("meta_mappings=s" => \$meta_mappings,
	   "debug"	=> \$debug );


die &usage() unless (-f $meta_mappings);

our $importer = BeastDB->new('dev');
$importer->connectDB();

sub meta_mappings
{
# create the meta mappings 
open (META_MAPPINGS, $meta_mappings) || die "can't open $meta_mappings!";
open (FAILED, ">failed-mappings.txt") || die "can't open failed-mappings.txt";
while (<META_MAPPINGS>) {
	my $line = $_;
	my ($parent, $null, $child) = split(/\t/, $line ); 
	chomp($parent);
	chomp($child);

	print "Adding parent child meta-meta relation: $parent:$child\n";

	my $id_parent = $importer->getMetaIdFromExternalId($parent);
	my $id_child = $importer->getMetaIdFromExternalId($child);
	if ($id_parent eq "") {
		print "no entry for meta: $parent, skipping relation...\n";
		print FAILED "$parent:$child\n";
		next;
	} elsif ($id_child eq "") {
		print "no entry for meta: $child, skipping relation...\n";
		print FAILED "$parent:$child\n";
		next;
	}

	if ($importer->existsMetaMetaRel($id_parent, $id_child) > 0) {
		print "relation already exists!\n";
	} else {
		print "no relation between meta's...adding\n";
		$importer->insertMetaMetaRel($id_parent, $id_child);
		unless ($importer->existsMetaMetaRel($id_parent, $id_child) > 0) {
			print "failed to add!!!\n";
		}
	}
	print "done\n";
}
close (FAILED);
close (META_MAPPINGS);
}

&meta_mappings;

$importer->disconnectDB();
