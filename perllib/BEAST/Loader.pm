#!/usr/local/bin/perl -w
#Author:	Evan Paull (epaull@soe.ucsc.edu)
#Create Date:	8.15.2010

use strict;
use warnings;
use lib "/projects/sysbio/map/Projects/BEAST/perllib";

use Data::Dumper;

package Loader;

sub new
{
	my $class = shift;
	my $beastDB = shift;

	my $self = { 'beastdb' => $beastDB };

	bless $self, $class;
	return $self;
}

sub addSet
{
	my $self = shift;

	my $set_name = shift;
	my $source = shift;

	my $importer = $self->{'beastdb'};

	my $set_internal_id = $importer->existsSet($set_name);
	if ($set_internal_id > 0) {
		print "set already exists in DB!: $set_name\n";
	} else {
		$set_internal_id = $importer->insertSet($set_name, $set_name);
		unless ($set_internal_id =~ /\d+/) { 
			print "failed to add set $set_name, quitting!\n";
			exit 1;	
		}
		print "Added set id:$set_internal_id for set $set_name\n";
		print "inserting info element for set: $set_name\n";
		my $meta_id = $importer->insertSQL("INSERT INTO sets_info (sets_id, name, value) VALUES ('".$set_internal_id."', 'source', '".$source."');");
		unless ($meta_id =~ /\d+/) {
			print "failed to add info for $set_name\n";
		}		
	}

	if ($set_internal_id =~ /\d+/) {
	#
	} else {
			print "Failed to add set $set_name!\n";
			exit 1;
	}
	return $set_internal_id;
}

sub addEntityToSet
{
	my $self = shift;

	my $entity_ext_id = shift;
	my $set_internal_id = shift;
	my $keyspace = shift;
	my $normalizedSCORE = shift;

	my $importer = $self->{'beastdb'};

	my $gene_id;
	if (($gene_id = $importer->existsEntity($entity_ext_id, $keyspace)) > 0) {
		print "already exists: $gene_id\n";
	} else {
		print "inserting : $entity_ext_id entity\n";
		$gene_id = $importer->insertEntity($entity_ext_id, 'NULL', $entity_ext_id, $keyspace);
	}

	if ($importer->existsSetEntityRel($set_internal_id, $gene_id) > 0) {
		print "set-entity rel already exists in DB!: $set_internal_id - $entity_ext_id\n";
	} else {
		print "no relation in DB, adding...\n";
		$importer->insertSetEntityRel($set_internal_id, $gene_id, $normalizedSCORE);
		unless ($importer->existsSetEntityRel($set_internal_id, $gene_id) > 0) {
			print "Failed to add!\n";	
		}
	}
}

1;
