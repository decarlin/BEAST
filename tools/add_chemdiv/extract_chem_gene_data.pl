#!/usr/local/bin/perl


use lib "/projects/sysbio/map/Projects/BEAST/perllib";
use strict;

sub usage 
{
	print <<EOF;
##
## Usage:  perl $0 --chemdata=raw_file 
##
EOF
}

use Getopt::Long;
use Math::BigFloat;
use BEAST::BeastDB;
use BEAST::Loader;

my $chemdata_file = '';
GetOptions("chemdata_file=s" => \$chemdata_file);

die &usage() unless (-f $chemdata_file);

# 1 -> ...
my $columns = []; 
my $lineno = 1;
open (CHD, $chemdata_file) || die;
while (my $line = <CHD>) {
	chomp($line);

	if ($lineno == 1) {
		my @column_names = split(/\t/,$line);
		# line 1 is the ORF
		for my $i (1 .. (scalar(@column_names) - 1)) {
			$columns->[$i] = { 
				'name' => $column_names[$i],
				'genes' => [],
			};	
		}
		$lineno++;
		next;
	}

	my @components = split(/\t/, $line);
	my $yeast_gene = $components[0];
	for my $i (1 .. (scalar(@$columns) - 1)) {
			push @{$columns->[$i]->{'genes'}}, { 'gene' => $yeast_gene, 'value' => $components[$i] };
	}	

	$lineno++;
}	
close (CHD);

#my $hash = $columns->[2];
#print "for chemical:".$hash->{'name'}."\n";
#foreach ( @{$hash->{'genes'}}) {
#	my $hash = $_;
#	print $hash->{'gene'}.":".$hash->{'value'};
#	print "\n";
#}

my $importer = BeastDB->new('dev');
$importer->connectDB();

my $loader = Loader->new($importer);

for my $i (1 .. (scalar(@$columns) - 1)) {
	my $column = $columns->[$i];
	my $column_name = $column->{'name'};
	my @genes = @{$column->{'genes'}};

	my $set_id = $loader->addSet($column_name, 'chemdiv');

	print "adding set: $set_id\n";
	$importer->insertSetMetaRel(202896, $set_id);
	next;
	

	foreach (@genes) {
		my $gene = $_;
		my $gene_name = $gene->{'gene'};
		my $membership_value = $gene->{'value'};
		$loader->addEntityToSet($gene_name, $set_id, '3', $membership_value);
	}	
}

$importer->disconnectDB();
