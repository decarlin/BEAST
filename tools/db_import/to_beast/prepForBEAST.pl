#!/usr/bin/perl -w
#####################################
#######    prepForBEAST.pl    #######
#####################################

use strict;
use warnings;
use lib "/soe/samb/bin";
use utils;          #contains useful, simple functions such as trim, max, min, and log_base
use lib "/projects/sysbio/www/cgi-bin/metatrans/";
use metatransDBHelper;

my $dbh = getDBHandle();
my $results;

sub doEntity($);
sub doSets($);
sub doMeta($);
sub doMetaMappings($);
sub doSetMember($);
sub doKeyspaces($);

#main
{
	my $output_dir = "/projects/sysbio/map/Papers/MetaTrans/perl/to_beast";

	#takes about 4 minutes
	print STDERR "doEntity: ".localtime()."\n";
	doEntity("$output_dir/elements_file.tab");

	#takes about 4 minute
	print STDERR "doSets: ".localtime()."\n";
	doSets("$output_dir/sets_file.tab");
	
	#takes about ? minutes
	print STDERR "doMeta: ".localtime()."\n";
	doMeta("$output_dir/metas_file.tab");

	#takes about ? minute
	print STDERR "doMetaMappings: ".localtime()."\n";
	doMetaMappings("$output_dir/meta_mappings_file.tab");

	#takes about 1 minute
	print STDERR "doSetMember: ".localtime()."\n";
	doSetMember("$output_dir/meta_sets_mappings_file.tab");

	#takes about 1 minute
	print STDERR "doKeyspaces: ".localtime()."\n";
	doKeyspaces("$output_dir/keyspaces_file.tab");

	print STDERR "Stop: ".localtime()."\n";


}# end main

sub doEntity($)
{
	my($output_file) = @_;
	my $entity_name = "";	#kegg gene_name
	my $entity_desc = "";	#kegg definition
	my $entity_key = "";	#kegg_id (protein_seq)
	my $keyspace_key = "";	#KEGG + organism_id
	my $organism_key = "";	#kegg organism id
	
	open(OUT_FILE, ">$output_file");
	
	my $select = "SELECT kps.gene_name, kps.definition, kps.kegg_id, ko.kegg_id ";
	my $from = "FROM kegg_protein_seqs kps, kegg_organisms ko ";
	my $where = "WHERE kps.kegg_organisms_id=ko.id";
	
	$results = runSQL("$select $from $where;", $dbh);
	
	while (my(@data) = $results->fetchrow_array())
	{
		$entity_name = fixData($data[0], "unknown");
		$entity_desc = fixData($data[1], "unknown");
		$entity_key = $data[2];
		$organism_key = $data[3];
		$keyspace_key = "KEGG^$organism_key";
		print OUT_FILE "$entity_name\t$entity_desc\t$entity_key\t$keyspace_key\n";
	}
	
	close(OUT_FILE);
}

#What kinds of sets?
#Sample + Organism
#Orthologs?
sub doSets($)
{
	my($output_file) = @_;
	my %sets_hash;

	my $set_key = "";
	my $entity_key = "";
	my $sample_id = "";
	my $organism_id = "";
	my $kegg_id = "";
	my $entity_value = "";

	
	open(OUT_FILE, ">$output_file");
	
	my $select = "SELECT s.sample, ko.kegg_id, kps.kegg_id, kpsc.normalized_count ";
	my $from = "FROM samples s, kegg_protein_seq_count kpsc, kegg_protein_seqs kps, kegg_organisms ko ";
	my $where = "WHERE s.id=kpsc.samples_id AND kpsc.kegg_protein_seqs_id=kps.id AND kps.kegg_organisms_id=ko.id ";
	
	$results = runSQL("$select $from $where;", $dbh);
	
	while (my(@data) = $results->fetchrow_array())
	{
		$sample_id = $data[0];		#sample name/station
		$organism_id = $data[1];	#organism kegg_id
		$entity_key = $data[2];		#protein sequence kegg_id
		$entity_value = $data[3];
		
		#16.11 is a round up from 16.1022727272727 found in the database...  just want to compress everything between 0 and 1
		$sets_hash{$sample_id}{$organism_id}{$entity_key} = ($entity_value/16.11);
	}


	foreach my $sample (keys %sets_hash)
	{
		foreach my $organism (keys %{$sets_hash{$sample}})
		{
			$set_key = "$sample\_$organism";
			print OUT_FILE "$set_key^desc=$sample\_$organism^source=marine_metatrans";
			foreach my $member (keys %{$sets_hash{$sample}{$organism}})
			{
				print OUT_FILE "\t$member^$sets_hash{$sample}{$organism}{$member}";
			}
			print OUT_FILE "\n";
		}
	}
	
	
	#now do ortholog "sets"
	my %ortholog_hash;
	my $ortholog_number;
	my $ortholog_name;
	my $ortholog_def;
	my $entity_id;
			
	$select = "SELECT ko.kegg_ko, ko.gene_name, ko.definition, kpso.id ";
	$from = "FROM kegg_protein_seqs kps, kegg_protein_seq_ortholog kpso, kegg_orthologs ko ";
	$where = "WHERE kps.id=kpso.kegg_protein_seqs_id AND kpso.kegg_orthologs_id=ko.id ";
	
	$results = runSQL("$select $from $where;", $dbh);
	
	while (my(@data) = $results->fetchrow_array())
	{
		$ortholog_number = $data[0];					#kegg ortholog number
		$ortholog_name = fixData($data[1], "unknown");	#kegg ortholog name
		$ortholog_def = fixData($data[2], "unknown");	#kegg ortholog decription
		$entity_id = $data[3];
		
		#16.11 is a round up from 16.1022727272727 found in the database...  just want to compress everything between 0 and 1
		$ortholog_hash{$ortholog_number}{'name'} = $ortholog_name;
		$ortholog_hash{$ortholog_number}{'def'} = $ortholog_def;
		push(@{$ortholog_hash{$ortholog_number}{'entities'}}, $entity_id);
	}


	foreach my $ortholog (keys %ortholog_hash)
	{
		$set_key = "$ortholog";
		print OUT_FILE "$ortholog^desc=".$ortholog_hash{$ortholog}{'name'}."^def=".$ortholog_hash{$ortholog}{'def'}."^source=kegg_orthologs";
		foreach my $entity (@{$ortholog_hash{$ortholog}{'entities'}})
		{
			print OUT_FILE "\t$entity";
		}
		print OUT_FILE "\n";
	}	
	
	close(OUT_FILE);
}

#samples (collection of sets of individual organisms)
#station organisms (collection of organisms per station)
#stations (collection of samples)
#pathways
sub doMeta($)
{
	my($output_file) = @_;
	my $sample = "";
	my $station = "";
	my $salinity = "";
	my $oxygen = "";
	my $temperature = "";
	my $lat = "";
	my $long = "";
	my $time = "";
	my $date = "";
	my $filter_size = "";
	open(OUT_FILE, ">$output_file");
	
	my $select = "SELECT s.sample, s.station_id, s.salinity, s.oxygen, s.temperature, s.latitude, s.longitude, s.local_time, s.local_date, s.filter_size";
	my $from = "FROM samples s";
	my $where = "";
	
	$results = runSQL("$select $from $where;", $dbh);
	
	while (my(@data) = $results->fetchrow_array())
	{
		$sample = $data[0];
		$station = $data[1];
		$salinity = fixData($data[2], "");
		$oxygen = fixData($data[3], "");
		$temperature = fixData($data[4], "");
		$lat = fixData($data[5], "");
		$long = fixData($data[6], "");
		$time = fixData($data[7], "");
		$date = fixData($data[8], "");
		$filter_size = fixData($data[9], "");
		
		print OUT_FILE "$sample\ttime:$time^date:$date^filter_size:$filter_size\n";
		print OUT_FILE "$station\tsalinity:$salinity^oxygen:$oxygen^temp:$temperature^lat:$lat^long:$long\n";
	}
	
	close(OUT_FILE);
}


sub doMetaMappings($)
{
	my($output_file) = @_;
	my $sample = "";
	my $station = "";
	
	open(OUT_FILE, ">$output_file");
	
	my $select = "SELECT s.sample, s.station_id";
	my $from = "FROM samples s";
	my $where = "";
	
	$results = runSQL("$select $from $where;", $dbh);
	
	while (my(@data) = $results->fetchrow_array())
	{
		$sample = $data[0];
		$station = $data[1];
		print OUT_FILE "$station\t$sample\n";
	}
	
	close(OUT_FILE);

}

#recreate the samples
sub doSetMember($)
{
	my($output_file) = @_;
	my %sets_hash;

	my $sample_id = "";
	my $organism_id = "";
	
	open(OUT_FILE, ">$output_file");
	
	my $select = "SELECT DISTINCT s.sample, ko.kegg_id ";
	my $from = "FROM samples s, kegg_protein_seq_count kpsc, kegg_protein_seqs kps, kegg_organisms ko ";
	my $where = "WHERE s.id=kpsc.samples_id AND kpsc.kegg_protein_seqs_id=kps.id AND kps.kegg_organisms_id=ko.id ";
	
	$results = runSQL("$select $from $where;", $dbh);
	
	while (my(@data) = $results->fetchrow_array())
	{
		$sample_id = $data[0];		#sample name/station
		$organism_id = $data[1];	#organism kegg_id
		
		$sets_hash{$sample_id}{$organism_id} = TRUE;
	}

	foreach my $sample (keys %sets_hash)
	{
		foreach my $organism (keys %{$sets_hash{$sample}})
		{
			print OUT_FILE "$sample\t$sample\_$organism\n";
		}
	}
	
	
	close(OUT_FILE);
}


#recreate the samples
sub doKeyspaces($)
{
	my($output_file) = @_;

	my $organism = "";
	my $desc = "";
	
	open(OUT_FILE, ">$output_file");
	
	my $select = "SELECT ko.kegg_id, ko.species_long ";
	my $from = "FROM kegg_organisms ko ";
	my $where = " ";
	
	$results = runSQL("$select $from $where;", $dbh);
	
	while (my(@data) = $results->fetchrow_array())
	{
		$organism = $data[0];		#sample name/station
		$desc = $data[1];	#organism kegg_id
		
		print OUT_FILE "$organism\tKEGG\t$desc\n";
	}
	
	
	close(OUT_FILE);
}







