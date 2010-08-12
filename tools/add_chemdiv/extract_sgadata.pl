#!/usr/local/bin/perl


use lib "/projects/sysbio/map/Projects/BEAST/perllib";
use strict;

sub usage 
{
	print <<EOF;
##
## Usage:  perl $0 --sgadata=raw_file 
##
EOF
}

sub convert_from_sci
{
	my $sci_val = shift;

	my $float = Math::BigFloat->new($sci_val);

	return $float;
}

use Getopt::Long;
use Math::BigFloat;
use BEAST::BeastDB;

my $sga_file = '';
GetOptions("sgadata=s" => \$sga_file);

die &usage() unless (-f $sga_file);

our $sga_interactions = {};

open (SGA, $sga_file) || die;
while (my $line = <SGA>) {
	chomp($line);	

	next if ($line =~ /^#/);	
	my (	$queryORF, 
		$queryGENE, 
		$arrayORF, 
		$arrayGENE,
		$interactionSCORE,
		$standardDEV,
		$pVAL
	) = split(/\t/, $line);

	#my $float_pVAL = convert_from_sci($pVAL);

	#print $queryGENE."\t".$queryGENE."\t".$arrayGENE."\t".$arrayGENE."\t".$interactionSCORE."\t".$standardDEV."\t".$float_pVAL."\n";	

	$queryGENE = uc($queryGENE);
	$arrayGENE = uc($arrayGENE);
	# map query_gene_name to 
	unless ($sga_interactions->{$queryGENE}) {
		$sga_interactions->{$queryGENE} = { $queryGENE => $interactionSCORE };
	} else {
		$sga_interactions->{$queryGENE}->{$queryGENE} = $interactionSCORE;
	}

	# now map the other
	unless ($sga_interactions->{$arrayGENE}) {
		$sga_interactions->{$arrayGENE} = { $queryGENE => $interactionSCORE };
	} else {
		$sga_interactions->{$arrayGENE}->{$queryGENE} = $interactionSCORE;
	}
}
close (SGA);

my $highestPOSITIVE = 0;
my $lowestNEGATIVE = 0;

foreach (keys %$sga_interactions) {
	my $gene = $_;
	foreach (keys %{$sga_interactions->{$gene}} ) {
		if ($sga_interactions->{$gene}->{$_} > $highestPOSITIVE) {
			$highestPOSITIVE = $sga_interactions->{$gene}->{$_};
		}
		if ($sga_interactions->{$gene}->{$_} < $lowestNEGATIVE) {
			$lowestNEGATIVE = $sga_interactions->{$gene}->{$_};
		}
	}
}
#print "lowest:".$lowestNEGATIVE."\n";
#print "highest:".$highestPOSITIVE."\n";

our $importer = BeastDB->new('dev');
$importer->connectDB();

# yeast
my $keyspace = 3;

foreach (keys %$sga_interactions) {

	my $gene = $_;

	# add the set
	my $set_id = $importer->existsSet($gene);
	if ($set_id > 0) {
		print "set already exists in DB!: $name\n";
	} else {
		#$id = $importer->insertSet($gene, $gene);
		if ($set_id =~ /\d+/) {
			print "Added set id:$set_id for set $gene\n";
			print "inserting info element for set: $name\n";
			my $meta_id = $importer->insertSQL("INSERT INTO sets_info (sets_id, name, value) VALUES (".$set_id.", 'source', 'boon_sga');");
			unless ($meta_id =~ /\d+/) {
				print "failed to get ID for $name\n";
			}		
		} else {
			print "Failed to add set $gene!\n";
		}
	}
	
	# add set type

	## first add each element to the database, then add the mapping
	foreach (keys %{$sga_interactions->{$gene}} ) {
		my $interaction_gene = $_;	
		my $score = $sga_interactions->{$gene}->{$interaction_gene};
		my $normalizedSCORE;
		if ($score > 0) {
			$normalizedSCORE = $score / $highestPOSITIVE;
		} else {
			$normalizedSCORE = $score / (-$lowestNEGATIVE);
		}
		# insert
		my $gene_id;
		if (($gene_id = $importer->existsEntity($interaction_gene, $keyspace)) > 0) {
			print "already exists: $gene_id\n";
		} else {
			print "inserting : $interaction_gene entity\n";
			#$id = $importer->insertEntity($interaction_gene, 'NULL', $interaction_gene, $keyspace);
		}

		if ($importer->existsSetEntityRel($set_id, $gene_id) > 0) {
			print "set already exists in DB!: $name\n";
		} else {
			print "no relation in DB, adding...\n";
			#$importer->insertSetEntityRel($set_id, $gene_id, $normalizedSCORE);
			unless ($importer->existsSetEntityRel($set_id, $gene_id) > 0) {
				print "Failed to add!\n";	
			}
		}
		
	}

}

$importer->disconnectDB();
