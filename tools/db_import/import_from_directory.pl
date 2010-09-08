#!/usr/local/bin/perl


use lib "/projects/sysbio/map/Projects/BEAST/perllib";
use strict;

sub usage 
{
	my $msg = shift;
	print <<EOF;
##
## Usage:  perl $0 --import_dir=dirpath --small_ent_mode --not_really
##
EOF
	print $msg."\n";	
}

use Getopt::Long;
use Math::BigFloat;
use BEAST::BeastDB;
use BEAST::Loader;
use BEAST::Entity;

$| = 1;

my $import_directory = '';
my $small_ent_mode = '';
my $not_really;
GetOptions(
	"import_dir=s" => \$import_directory,
	"not_really+" => \$not_really,
	"small_ent_mode+" => \$small_ent_mode);

die &usage() unless (-d $import_directory);

my $keyspaces_file = $import_directory."/keyspaces.tab";
my $elements_file = $import_directory."/elements.tab";
my $sets_file = $import_directory."/sets.tab";
my $meta_file = $import_directory."/metas.tab";
my $meta_mappings_file = $import_directory."/meta_mappings.tab";
my $meta_sets_mappings_file = $import_directory."/meta_sets_mappings.tab";

die &usage('no keyspace file') unless (-f $keyspaces_file);
die &usage('no sets file') unless (-f $sets_file);
die &usage('no elements file') unless (-f $elements_file);
die &usage('no meta file') unless (-f $meta_file);
die &usage('no meta mappings file') unless (-f $meta_mappings_file);
die &usage('no meta sets mappings file') unless (-f $meta_sets_mappings_file);

my $keyspaces = {};
my @keyspace_lines;
if (-f $keyspaces_file) {
	open (KEYSPACE, $keyspaces_file) || die;
	@keyspace_lines = <KEYSPACE>;
	close (KEYSPACE);
}

my $entities = {};

my @sets;
if (-f $sets_file) {
	open (SETS_FH, $sets_file) || die;
	my @lines = <SETS_FH>;
	my $errstr = '';
	@sets = Set::parseSetLines(\$errstr, @lines);
	my $sets_hash = {};
	close (SETS_FH);
	if ($sets[0] == 0) {
		pop @sets;
		print $errstr."\n";
		die "Failed to parse set lines!\n";
	}
}

my @meta_lines;
if (-f $meta_file) {
	open (META, $meta_file) || die;
	@meta_lines = <META>;
	close (META);
}

my @meta_mapping_lines;
if (-f $meta_mappings_file) {
	open (META_MAP, $meta_mappings_file) || die;
	@meta_mapping_lines = <META_MAP>;
	close (META_MAP);
}

my @meta_sets_mapping_lines;
if (-f $meta_sets_mappings_file) {
	open (META_SETS, $meta_sets_mappings_file) || die;
	@meta_sets_mapping_lines = <META_SETS>;
	close (META_SETS);
}



# open DBH
my $importer;
if ($not_really) {
	$importer = BeastDB->new();
} else {
	$importer = BeastDB->new('dev');
}
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

sub add_elements
{
print "\n -------------------------- \n";
print "ADDING ENTITIES TO DB ";
print "\n -------------------------- \n";
open (ELS, $elements_file) || die;
foreach my $line (<ELS>) {
	chomp $line;

	my $err_str;
	my ($name, $desc, $ex_id, $keyspace) = split (/\t/, $line);

	# $keyspace should be source^organism

	my $entity = Entity->new($name, $desc, $ex_id, $keyspaces->{$keyspace});
	my $internal_id = $entity->insertDB($importer, \$err_str);
	print $err_str."\n";

	# save for the sets
	$entity->set_id($internal_id);
	if ($small_ent_mode) {
		$entities->{$name} = $entity;
	}
}
close (ELS);

}

sub add_sets
{
print "\n -------------------------- \n";
print "ADDING SETS TO DB ";
print "\n -------------------------- \n";
foreach my $set (@sets) {
	my $err_str;
	if ($small_ent_mode) {
		$set->insertDB($importer, $entities, \$err_str);
	} else {
		$set->insertDB($importer, "", \$err_str);
	}
	print $err_str."\n";
}
}

my $meta_hash = {};
sub add_metas
{

print "\n -------------------------- \n";
print "ADDING METAS TO DB ";
print "\n -------------------------- \n";
foreach my $line (@meta_lines) {
	chomp $line;

	my $err_str;

	my ($external_id, $name) = split(/\t/, $line);		
	my $metadata = { 'type' => 'meta', 'name' => $name, 'ex_id' => $external_id };
	my $meta = Set->new($external_id, 1, $metadata, "");
	$meta->insertDB($importer, $entities, \$err_str);
	$meta_hash->{$meta->get_ex_id} = $meta;
	print $err_str."\n";
}
}

sub add_meta_mappings
{

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

}

sub add_meta_set_mappings
{

print "\n -------------------------- \n";
print "ADDING META SET MAPPINGS TO DB ";
print "\n -------------------------- \n";
foreach my $line (@meta_sets_mapping_lines) {
	chomp $line;

	my ($meta_parent_ex_id, $set_child_ex_id) = split(/\t/, $line);		
	my $set_id = $importer->existsSet($set_child_ex_id);
	my $meta_id = $importer->existsMeta($meta_parent_ex_id);

	if ($set_id > 0 && $meta_id > 0) {	
	$importer->insertSetMetaRel($meta_id, $set_id);
	print "added meta $meta_parent_ex_id to set $set_child_ex_id relation\n";
	} else {
		print "can't add meta: $meta_parent_ex_id\n";	
	}
	
}

}

#&add_elements;
#&add_metas;
#&add_meta_mappings;
&add_sets;
&add_meta_set_mappings;
print "DONE! \n\n";
# close DB
$importer->disconnectDB();
