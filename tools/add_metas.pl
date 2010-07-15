#!/usr/local/bin/perl

use lib "/projects/sysbio/map/Projects/BEAST/perllib";

sub usage 
{
	print <<EOF;
##
## Usage:  perl metas_insert.pl --meta=file1 
## (insert the meta sets)
##
EOF
}


use BEAST::BeastDB;

use Getopt::Long;

my $metas_file = '';
my $meta_mappings = '';
my $debug = '';
GetOptions("meta=s" => \$metas_file,
	   "debug"	=> \$debug );


die &usage() unless (-f $metas_file);

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

&insert_metas;

$importer->disconnectDB();
