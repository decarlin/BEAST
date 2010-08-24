#!/usr/local/bin/perl


use lib "/projects/sysbio/map/Projects/BEAST/perllib";
use strict;

sub usage 
{
	my $msg = shift;
	print <<EOF;
##
## Usage:  perl $0 --import_dir=dirpath
##
EOF
	print $msg."\n";	
}

use Getopt::Long;
use Math::BigFloat;
use BEAST::BeastDB;
use BEAST::Loader;
use BEAST::Entity;

my $import_directory = '';
GetOptions("import_dir=s" => \$import_directory);

die &usage() unless (-d $import_directory);

my $keyspaces_file = $import_directory."/keyspaces.tab";
my $elements_file = $import_directory."/elements.tab";
my $sets_file = $import_directory."/sets.tab";
my $meta_file = $import_directory."/metas.tab";
my $meta_mappings_file = $import_directory."/meta_mappings.tab";
my $meta_sets_mappings_file = $import_directory."/meta_sets_mappings.tab";

die &usage('no sets file') unless (-f $sets_file);
die &usage('no elements file') unless (-f $elements_file);
die &usage('no meta file') unless (-f $meta_file);
die &usage('no meta mappings file') unless (-f $meta_mappings_file);
die &usage('no meta sets mappings file') unless (-f $meta_sets_mappings_file);

my $keyspaces = {};
open (KEYSPACE, $keyspaces_file) || die;
my @keyspace_lines = <KEYSPACE>;
close (KEYSPACE);

my $entities = {};

open (SETS_FH, $sets_file) || die;
my @lines = <SETS_FH>;
my @sets = Set::parseSetLines(@lines);
my $sets_hash = {};
close (SETS_FH);
if ($sets[0] == 0) {
	pop @sets;
	die "Failed to parse set lines!\n";
}

open (META, $meta_file) || die;
my @meta_lines = <META>;
close (META);

open (META_MAP, $meta_mappings_file) || die;
my @meta_mapping_lines = <META_MAP>;
close (META_MAP);

open (META_SETS, $meta_sets_mappings_file) || die;
my @meta_sets_mapping_lines = <META_SETS>;
close (META_SETS);



# open DBH
my $importer = BeastDB->new('test');
$importer->connectDB();

# build keyspaces map
print "\n -------------------------- \n";
print "ADDING KEYSPACES TO DB ";
print "\n -------------------------- \n";
foreach my $line (@keyspace_lines) {

	my ($organism, $source, $desc) = split(/\t/, $line);
	chomp ($desc);

	my $keyspace_id;
	unless ( ($keyspace_id = $importer->existsKeyspace($organism, $source)) > 0) {
		$keyspace_id = $importer->insertKeyspace($organism, $source, $desc);
		print "added keyspace: $keyspace_id\n";
		if ($keyspace_id == 0) { die "bad keyspace insertion!"; }
	}

	$keyspaces->{$source."^".$organism} = $keyspace_id;
}

print "\n -------------------------- \n";
print "ADDING ENTITIES TO DB ";
print "\n -------------------------- \n";
my $err_str;
open (ELS, $elements_file) || die;
foreach my $line (<ELS>) {
	chomp $line;

	my ($name, $desc, $ex_id, $keyspace) = split (/\t/, $line);

	# $keyspace should be source^organism

	my $entity = Entity->new($name, $desc, $ex_id, $keyspaces->{$keyspace});
	my $internal_id = $entity->insertDB($importer, \$err_str);
	print $err_str."\n";

	# save for the sets
	$entity->set_id($internal_id);
	$entities->{$name} = $entity;
}
close (ELS);

print "\n -------------------------- \n";
print "ADDING SETS TO DB ";
print "\n -------------------------- \n";
my $sets_hash = {};
foreach my $set (@sets) {
	$set->insertDB($importer, $entities, \$err_str);
	$sets_hash->{$set->get_name} = $set;
	print $err_str."\n";
}

print "\n -------------------------- \n";
print "ADDING METAS TO DB ";
print "\n -------------------------- \n";
my $meta_hash = {};
foreach my $line (@meta_lines) {
	chomp $line;

	my ($external_id, $name) = split(/\t/, $line);		
	my $metadata = { 'type' => 'meta', 'name' => $name, 'ex_id' => $external_id };
	my $meta = Set->new($external_id, 1, $metadata, "");
	$meta->insertDB($importer, $entities, \$err_str);
	$meta_hash->{$meta->get_ex_id} = $meta;
	print $err_str."\n";
}

print "\n -------------------------- \n";
print "ADDING META MAPPINGS TO DB";
print "\n -------------------------- \n";
foreach my $line (@meta_mapping_lines) {
	chomp $line;

	my ($parent_n, $child_n) = split(/\t/, $line);		
	my $parent = $meta_hash->{$parent_n};
	my $child = $meta_hash->{$child_n};

	if ($importer->existsMetaMetaRel($parent->get_id, $child->get_id) > 0) {
		print "relation already exists!\n";
	} else {
		print "no relation between meta's...adding\n";
		$importer->insertMetaMetaRel($parent->get_id, $child->get_id);
		unless ($importer->existsMetaMetaRel($parent->get_id, $child->get_id) > 0) {
			print "failed to add!!!\n";
		}
	}

}

print "\n -------------------------- \n";
print "ADDING META SET MAPPINGS TO DB ";
print "\n -------------------------- \n";
foreach my $line (@meta_sets_mapping_lines) {
	chomp $line;

	my ($meta_parent_name, $set_child_name) = split(/\t/, $line);		
	my $set = $sets_hash->{$set_child_name};
	my $meta = $meta_hash->{$meta_parent_name};

	$importer->insertSetMetaRel($meta->get_id, $set->get_id);;
	print "added meta $meta_parent_name to set $set_child_name relation\n";
}

print "DONE! \n\n";
# close DB
$importer->disconnectDB();
