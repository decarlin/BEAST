#!/usr/local/bin/perl


sub usage 
{
	print <<EOF;
##
## Usage:  perl metas_insert.pl --meta=file1 --meta_sets=file2 
## (insert the meta sets and mappings between them in one go)
##
EOF
}


use BEAST::ImportSets;

use Getopt::Long;

my $metas_file = '';
my $meta_mappings = '';
GetOptions("meta=s" => \$metas_file,
	   "meta_sets=s" => \$meta_mappings);


die &usage() unless (-f $metas_file);
die &usage() unless (-f $meta_mappings);

our $importer = ImportSets->new;
$importer->connectDB();

## mapping between internal keys and external
my $metas = {
	#'external_id' => id,
};

# run the meta inserts
open (METAS,$metas_file) || die "can't open $metas_file!";
while (<METAS>) {
	my ($ex_id, $name) = split(/\t/, $_);
	chomp($ex_id);
	chomp($name);

	my $id = $importer->insertMeta($ex_id, $name);
	$metas->{$ex_id} = $id;
	print "Added meta id:$id for meta $ex_id\n";
}
close (METAS);

# create the meta mappings 
open (META_MAPPINGS, $meta_mappings) || die "can't open $meta_mappings!";
while (<META_MAPPINGS>) {
	my ($parent, $null, $child) = split(/\t/, $_ ); 
	chomp($parent);
	chomp($child);
	my $id_parent = $metas->{$parent};
	my $id_child = $metas->{$child};

	print "Adding parent child meta-meta relation: $parent:$child\n";
	$importer->insertMetaMeta($id_parent, "NULL", $id_child);
}
close (META_MAPPINGS);

$importer->disconnectDB();
