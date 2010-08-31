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
	# add the query gene- array gene interactions
	unless ($sga_interactions->{$queryGENE}) {
		$sga_interactions->{$queryGENE} = { $arrayGENE => $interactionSCORE };
	} else {
		$sga_interactions->{$queryGENE}->{$arrayGENE} = $interactionSCORE;
	}

	# now map the other
	#unless ($sga_interactions->{$arrayGENE}) {
	#	$sga_interactions->{$arrayGENE} = { $queryGENE => $interactionSCORE };
	#} else {
	#	$sga_interactions->{$arrayGENE}->{$queryGENE} = $interactionSCORE;
	#}
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
	
#my $meta_id;
#my $meta_external_id = "boon_sga";
#my $meta_name = "Boon Syn Lethals of Yeast Knockouts";
#if (($meta_id = $importer->existsMeta($meta_external_id)) == 0) {
##	print "doesn't exist: $meta_external_id!...adding...\n";
#	$meta_id = $importer->insertMeta($meta_external_id, $meta_name);
#} else {
#	print "Meta already exists! id:$meta_id\n";
#}
#foreach (keys %$sga_interactions) {
#
#	my $gene = $_;
#
#	print "Query Gene: $gene\n";
#	foreach (keys %{$sga_interactions->{$gene}}) {
#		print "\t$_\n";
#	}
##}
#
#exit;
#

foreach my $gene (keys %$sga_interactions) {

	# add the set
	my $set_id = $importer->existsSet($gene);
	#print "adding set: $set_id\n";
	#$importer->insertSetMetaRel(202895, $set_id);
	#next;

	if ($set_id > 0) {
		print "set already exists in DB!: $gene\n";
	} else {
		$set_id = $importer->insertSet("Query Gene: $gene Syn Lethal Neighbors", $gene);
		unless ($set_id =~ /\d+/) { 
			print "failed to add set $gene, quitting!\n";
			exit 1;	
		}
		print "Added set id:$set_id for set $gene\n";
		print "inserting info element for set: $gene\n";
		my $meta_id = $importer->insertSQL("INSERT INTO sets_info (sets_id, name, value) VALUES ('".$set_id."', 'source', 'boon_sga');");
		unless ($meta_id =~ /\d+/) {
			print "failed to add info for $gene\n";
		}		

		# here we map the set to the entity id, since this syn lethal set represents a real entity in the database
		my $gene_id;
		if (($gene_id = $importer->existsEntity($gene, $keyspace)) > 0) {
			print "inserting entity info element for set: $gene\n";
			my $meta_id = $importer->insertSQL("INSERT INTO sets_info (sets_id, name, value) VALUES ('".$set_id."', 'entity', '$gene_id');");
			$importer->insertSQL("INSERT INTO sets_info (sets_id, name, value) VALUES ('".$set_id."', 'type', 'query_gene');");
		}		
	}

	if ($set_id =~ /\d+/) {
	#
	} else {
			print "Failed to add set $gene!\n";
			exit 1;
	}
	
	# add set type
	# add meta:

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
			$gene_id = $importer->insertEntity($interaction_gene, 'NULL', $interaction_gene, $keyspace);
		}

		if ($importer->existsSetEntityRel($set_id, $gene_id) > 0) {
			print "set-entity rel already exists in DB!: $gene - $interaction_gene\n";
		} else {
			print "no relation in DB, adding...\n";
			$importer->insertSetEntityRel($set_id, $gene_id, $normalizedSCORE);
			unless ($importer->existsSetEntityRel($set_id, $gene_id) > 0) {
				print "Failed to add!\n";	
			}
		}
		
	}

}


$importer->disconnectDB();
