#!/usr/bin/perl -w
#Author:	Evan Paull (epaull@soe.ucsc.edu)
#Create Date:	6.16.2010

use strict;
use warnings;
use lib "/projects/sysbio/map/Projects/BEAST/perllib";
use lib "/var/www/cgi-bin/BEAST/perllib";
# JSON object serialization
use BEAST::Set;
use BEAST::Collection;
use BEAST::Cluster;
use JSON -convert_blessed_universally;

our $TRUE = 1;
our $FALSE = 0;

package ClusteredCollection;

use base qw(Collection);
# stores an ordered list of set names -- but not the 
# set data 

sub new
{
	my $class = shift;
	if (ref($class) eq 'ClusteredCollection') { 
		$class = 'ClusteredCollection';
	}

	# hash ref
	my $self;

	if (@_ == 1) {
		my $json_text = shift;
		my $json = JSON->new->utf8;
		$self = $json->decode($json_text);
	} elsif (ref($_[1]) eq 'Set') {

		my $name = shift;
		$self = {'_name' => $name };

		my @sets = @_;
		$self->{'sets'} = [];
		foreach (@sets) {
			my $set = $_;
			die unless (ref($set) eq 'Set');

			# we're not saving the sets here -- just pointing to the names
			push @{$self->{'sets'}}, $set->get_name;
	  	}

	} else {

		my $name = shift;
		$self = {'_name' => $name };

		my @names = @_;
		$self->{'sets'} = [];
		foreach (@names) {
			# we're not saving the sets here -- just pointing to the names
			push @{$self->{'sets'}}, $_;
	  	}

	}

	bless $self, $class;
	return $self;
}

# call after re-clustering -- re-order according to the 
sub recluster
{
	my $self = shift;
	my $session_id = shift;
	# the set objects for this collection
	my @sets = @_;

	# for the trivial case of only one set:
	# set the cluster anyways, as the single set 
	if (scalar(@sets) == 1) {
		my $new_cluster = Set->new($self->get_name, 1, {'type' => 'meta_display'}, {});
		$new_cluster->set_element($sets[0]->get_name, $sets[0]);
		$self->{'cluster'} = $new_cluster;
		return 1;
	} elsif (scalar(@sets) == 0) {
		print "Error: cannot null sets!";
		return 0;
	}


	my $clusterizer = Cluster->new($session_id, @sets);
	unless ($clusterizer->run > 0) {
		print "Failed to run cluster-eisen!";
		return 0;
	}
	my @clusters = $clusterizer->get_clusters;


	# debug
	#$clusterizer->print_atr_output;

	my $new_cluster = Set->new($self->get_name, 1, {'type' => 'meta_display'}, {});
	foreach my $cluster (@clusters) {
		$new_cluster->set_element($cluster->get_name, $cluster);
	}
	$self->{'cluster'} = $new_cluster;

	# now redo the order of the set names
	my @leaves = $new_cluster->getLeafNodes;

	my @current_names = @{$self->{'sets'}};
	my $all_sets_hash = {};
	foreach my $name (@current_names) {
		$all_sets_hash->{$name} = 1;	
	}

	# add the cluster to the beginning of the set
	$self->{'sets'} = [];
	foreach my $leaf (@leaves) {

		next unless ($leaf->get_type eq 'set');
		# we're not saving the sets here -- just pointing to the names
		push @{$self->{'sets'}}, $leaf->get_name;
		delete $all_sets_hash->{$leaf->get_name};
  	}

	# add the remaining, non clustered set names
	foreach my $name (keys %$all_sets_hash) {
		push @{$self->{'sets'}}, $name;
	}
}

# WARNINGS:
# - no duplicate sets!
# - @sets must be a superset of the collection sets
sub order_sets
{
	my $self = shift;
	my @sets = @_;

	my $lookup = {};
	foreach my $set (@sets) {
		$lookup->{$set->get_name} = $set;
	}		

	my @sorted_sets;

	foreach my $name (@{$self->{'sets'}}) {
		unless (exists ($lookup->{$name})) {
			#print Data::Dumper->Dump([@sets]);
			die "\@sets not a superset of cluster sets".$name;
		}
		push @sorted_sets, $lookup->{$name};
		delete $lookup->{$name};
	}

	# add the rest that aren't in this cluster
	foreach my $name (keys %$lookup) {
		push @sorted_sets, $lookup->{$name};
	}

	return @sorted_sets;
}

sub get_cluster
{
	my $self = shift;

	return $self->{'cluster'};
}


1;
