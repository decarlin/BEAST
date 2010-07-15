#!/usr/local/bin/perl

use lib "/projects/sysbio/map/Projects/BEAST/perllib";

sub usage 
{
	print <<EOF;
##
## Usage:  perl metas_insert.pl --meta=file1 --meta_sets=file2 
## (insert the meta sets and mappings between them in one go)
##
EOF
}


use BEAST::BeastDB;

use Getopt::Long;

my $metas_file = '';
my $meta_mappings = '';
my $debug = '';
GetOptions("meta=s" => \$metas_file,
	   "meta_sets=s" => \$meta_mappings,
	   "debug"	=> \$debug );


die &usage() unless (-f $metas_file);
die &usage() unless (-f $meta_mappings);

our $importer = BeastDB->new('dev');
$importer->connectDB();

## mapping between internal keys and external
my $metas = {
	#'external_id' => id,
};

sub insert_metas
{
# run the meta inserts
open (METAS,$metas_file) || die "can't open $metas_file!";
while (<METAS>) {
	my ($ex_id, $name) = split(/\t/, $_);
	chomp($ex_id);
	chomp($name);

	my $id;
	if (($id = $importer->existsMeta($ex_id)) == 0) {
		print "doesn't exist: $ex_id!...adding...\n";
		$id = $importer->insertMeta($ex_id, $name);
	} else {
		print "Meta already exists! id:$id\n";
		$metas->{$ex_id} = $id;
		next;
	}
	$metas->{$ex_id} = $id;
	if ($id =~ /\d+/) {
		print "Added meta id:$id for meta $ex_id\n";
	} else {
		print "Failed to add meta id: $ex_id!\n";
	}
	
}
close (METAS);

}

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

	if ($importer->existsMetaMetaRel($id_parent, "NULL", $id_child) > 0) {
		print "relation already exists!\n";
	} else {
		print "no relation between meta's...adding\n";
		$importer->insertMetaMetaRel($id_parent, "NULL", $id_child);
	}
	print "done\n";
}
close (FAILED);
close (META_MAPPINGS);

$importer->disconnectDB();
