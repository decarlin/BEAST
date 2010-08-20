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

my $elements_file = $import_directory."/elements_file.tab";
my $sets_file = $import_directory."/sets_file.tab";
my $meta_file = $import_directory."/metas_file.tab";
my $meta_mappings_file = $import_directory."/meta_mappings_file.tab";
my $meta_sets_mappings_file = $import_directory."/meta_sets_mappings_file.tab";

die &usage('no sets file') unless (-f $sets_file);
die &usage('no elements file') unless (-f $elements_file);
#die &usage('no meta file') unless (-f $meta_file);
#die &usage('no meta mappings file') unless (-f $meta_mappings_file);
#die &usage('no meta sets mappings file') unless (-f $meta_sets_mappings_file);

my $entities = {};
open (ELS, $elements_file) || die;
my @ent_lines = <ELS>;
close (ELS);

open (SETS_FH, $sets_file) || die;
my @lines = <SETS_FH>;
my @sets = Set::parseSetLines(@lines);
close (SETS_FH);
if ($sets[0] == 0) {
	pop @sets;
	die "Failed to parse set lines!\n";
}

# open DBH
my $importer = BeastDB->new('test');
$importer->connectDB();

my $err_str;
foreach my $line (@ent_lines) {
	chomp $line;

	my ($name, $desc, $ex_id, $keyspace) = split (/\t/, $line);

	my $entity = Entity->new($name, $desc, $ex_id, $keyspace);
	my $internal_id = $entity->insertDB($importer, \$err_str);
	print $err_str."\n";

	# save for the sets
	$entity->set_id($internal_id);
	$entities->{$name} = $entity;
}

foreach my $set (@sets) {
	$set->insertDB($importer, $entities, \$err_str);
	print $err_str."\n";
}

# close DB
$importer->disconnectDB();
