#!/usr/bin/perl -w
#Author:	Evan Paull (epaull@soe.ucsc.edu)
#Create Date:	6.16.2010

use strict;
use warnings;
use lib "/projects/sysbio/map/Projects/BEAST/perllib";
use DBI;
# JSON object serialization
use JSON -convert_blessed_universally;

our $TRUE = 1;
our $FALSE = 0;

package Set;

##
## Static Methods: parseSetLines
##

sub new
{
	my $class = shift;
	# hash ref

	my $self;
	if (@_ >= 2) {
		my $name = shift;
		my $active = shift;
		my $metadata = shift;
		my $elements = shift;

		$self = {
			'_name' 	=> $name,
			# boolean 1=yes, 0=no 
			'_active'	=> $active,
	 		'_metadata' 	=> $metadata,
			#'_metadata' 	=> { 'key2 => 'value1',
			# 		     'key2 => 'value2
			'_elements'	=> $elements,
			# '_elements'	=> { 'name' 	=>  $setObj1,
			#		     'name2' 	=>  $setObj2
			'_delim'	=> '^',
		};
	} elsif (@_ == 1) {
		my $json_text = shift;

		my $json = JSON->new->utf8;
		$self = $json->decode($json_text);
	} elsif (!@_) {
		die "Set::new method called without arguments!";
	}

	bless $self, $class;
	return $self;
}

# this converts it to a json string
sub serialize
{
	my $self = shift;
	
	my $json = JSON->new->utf8;
	$json = $json->convert_blessed([1]);
	my $json_text = $json->encode($self);

	return $json_text;
}

sub get_name
{
	my $self = shift;
	return $self->{'_name'};
}

sub get_element
{
	my $self = shift;
	my $element_name = shift;

	unless (exists($self->{'_elements'}->{$element_name})) { return ($FALSE, ""); }
	return ($TRUE, $self->{'_elements'}->{$element_name});
}

sub set_element
{
	my $self = shift;
	my $element_name = shift;
	my $element = shift;

	$self->{'_elements'}->{$element_name} = $element;
}

sub get_element_names
{
	my $self = shift;

	return (keys %{$self->{'_elements'}});	
}

sub get_metadata_value
{
	my $self = shift;
	my $key = shift;

	return $self->{'_metadata'}->{$key};
}

#
# Find a place where they differ, then add the second tree's subsets to the first 
# tree's subsets
#
sub mergeTree($)
{
	my $self = shift;
	my $tree2 = shift;

	#different head nodes always means we can't merge
	unless ($self->get_name eq $tree2->get_name) {
		return $FALSE;
	}

	my @children_of_1 = $self->get_element_names;
	my @children_of_2 = $tree2->get_element_names;

	my @children_only_in_tree_2;


	foreach (@children_of_2)
	{
		my $child = $_;
		my $found = $FALSE;
		
		foreach (@children_of_1) {
			if ($child eq $_) {
				$found = $TRUE;	
				last;
			}
		}

		# this is in tree 2, but not in tree 1, so add the element to tree 1	
		my $element = $tree2->get_element($child);
		if ($found == $FALSE) {
			$self->set_element($child, $element); 
		} else {
		# otherwise they both have the same node -- merge the subnodes
			my $subtree = $self->get_element($child);
			$subtree->mergeTree($element);	
		}
	}

	return $TRUE;
}

# Disjoint trees
# instance method
sub mergeTrees
{
	my $self = shift;
	my @trees = shift;

	foreach (@trees) {
		my $tree = $_;
		if ($self->mergeTree($tree) > 0) {
			# stop at the first successful merge: 
			# @trees are mutually disjoint, so 
			# if it matches one, it must not match any other
			# tree of the collection
			return $tree->get_name;
		}
	}

	return $FALSE;
}

##
## REQUIRE: Sets in each collection are mutually disjoint!!
##
## Static method; satisfies transitivity among merges, 
## assuming that both sets of sets are disjoint 
##
## Given collection 1 of mutually disjoint trees, and a
## collection 2 of mutually disjoint trees, we can assume
## that (because the top nodes must match to have an overlap)
## if a given tree -A- from collection 1 does match another
## tree from collection 2 -B-, then it must not match any other
## tree from collection 2, from the mutual disjoint property.
## At that point, we can terminate the loop
sub mergeDisjointCollections
{
	my $collection1REF = shift;
	my $collection2REF = shift;

	my @collection2 = @{$collection2REF};

	foreach (@{$collection1REF}) {

		my $retval = $_->mergeDisjointTrees(@collection2);
	
		# no match
		next if ($retval eq $FALSE);

		# remove whichever tree of collection 2 matched -- since collections are 
		# disjoint, it won't match any other trees in collection 2
		@collection2 = removeTreeFromCollection($retval, @collection2);
	}
}

sub removeTreeFromCollection
{
	my $nameToRemove = shift;
	my @collection = @_;

	my @pared_collection;
	foreach (@collection) {
		unless ($_->get_name eq $nameToRemove) {
		  push @pared_collection, $_;
		}
	}

	return @pared_collection;
}



1;
