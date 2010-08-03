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
## Static Methods: parseSetLines, sortByName
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

		# self, and all it's elements are just hash refs now
		# -- we need to recursively bless each into being a 'Set' object
		foreach (keys %{$self->{'_elements'}}) {
			my $element_name = $_;
			#next unless ($element_name =~ /:/);
			# element is just a gene name
			next unless (ref($self->{'_elements'}->{$element_name}) eq 'HASH');

			# element is another set -- create it
			$self->{'_elements'}->{$element_name} = Set->new($json->encode($self->{'_elements'}->{$element_name}));
		}

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

sub get_id
{
	my $self = shift;
	my $id = $self->get_metadata_value('id');

	return ($id =~ /\d+/) ? $id : undef;	
}

sub is_active
{
	my $self = shift;
	return $self->{'_active'};
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

sub set_element_inactive
{
	my $self = shift;
	my $element_name = shift;

	$self->{'_elements'}->{$element_name}->{'_active'} = 0;
}

sub delete_element
{
	my $self = shift;
	my $element_name = shift;

	if (exists($self->{'_elements'}->{$element_name})) { 
		delete($self->{'_elements'}->{$element_name});
	}
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

	unless (ref($self) eq 'Set' && ref($tree2) eq 'Set') {
		return $FALSE;
	}
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

			# these must both be sets for the merge to be meaningful
			next unless (ref($subtree) eq 'Set');
			next unless (ref($element) eq 'Set');

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

	my @merged_trees;
	foreach (@{$collection1REF}) {

		my $tree = $_;
		my $retval = $tree->mergeTrees(@collection2);
	
		# no match
		next if ($retval eq $FALSE);

		# remove whichever tree of collection 2 matched -- since collections are 
		# disjoint, it won't match any other trees in collection 2
		@collection2 = removeTreeFromCollection($retval, @collection2);
	}

	# whatever hasn't been removed from collection 2 has had no match, so 
	# we can remove it now
	@merged_trees = (@{$collection1REF}, @collection2);
	return @merged_trees;
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

sub mergeCheckbox_Remove
{
	my $self = shift;
	my $checkboxHash = shift;

	foreach ($self->get_element_names) {
		my $name = $_;
		my $element = $self->get_element($name);

		if (exists $checkboxHash->{$name}) {
		  if (ref($element) eq 'Set') {
			$element->mergeCheckbox_Remove($checkboxHash);
		  }
		} else {
		  #delete it
		  if (ref($element) eq 'Set') {
		  	$self->delete_element($name);
		  } 
			# don't delete scalar elements
		}
	}
}

sub mergeCheckbox_Inactivate
{
	my $self = shift;
	my $checkboxHash = shift;

	foreach ($self->get_element_names) {
		my $name = $_;
	 	my $element = $self->get_element($name);
	     
		unless (exists $checkboxHash->{$name}) {
	  	  if (ref($element) eq 'Set') {
			$self->set_element_inactive($name);
		  } else {
			#how to inactivate a gene???
		  } 
		}
	  	if (ref($element) eq 'Set') {
			$element->mergeCheckbox_Inactivate($checkboxHash);
	  	}
	}
}

sub getLeafNodes()
{
	my $self = shift;	

	my @leafnodes;	

	my @names = $self->get_element_names;
	if ($#names == -1) { push @leafnodes, $self; }

	my $set_isa_leaf = $TRUE;
	foreach (@names) {
		my $name = $_;
	 	my $element = $self->get_element($name);
	     
	  	next unless (ref($element) eq 'Set');

		$set_isa_leaf = $FALSE;

		my $isleaf = $TRUE;
		foreach ($element->get_element_names) {
			my $subelement = $element->get_element($_);
			if (ref($subelement) eq 'Set') {
				my @subleaves = $subelement->getLeafNodes;
				push @leafnodes, @subleaves;
				$isleaf = $FALSE;
			}
		}

		if ($isleaf == $TRUE) { 
			push @leafnodes, $element; 
		}
	}

	if ($set_isa_leaf == $TRUE) {
		push @leafnodes, $self;
	}

	return @leafnodes;
}

sub parseSetLines
{
	my @lines = @_;

	my @sets;

	for my $line (@lines) 
	{
		chomp($line);

		#fail 1
		unless ($line =~ /\S+\t\S+/) {
			return 0;
		}

		my @components = split(/\t/, $line);

		unless ($line =~ /\^/) {
			return 0;
		}

		my @meta_components;
		my $name;
		($name, @meta_components) = split(/\^/, $components[0]);
		
		if ($name =~ /=/) {
			return 0;
		}

		my $metadata = {};
		foreach (@meta_components) {
			if ($_ =~ /(.*)=(.*)/) {
				  $metadata->{$1} = $2;
			} else {
				return 0;
			} 
		}
		
		my $elements = {};
		for my $i (1 .. $#components) 
		{
			$elements->{$components[$i]} = "";	
		}

		my $set = Set->new($name, "1", $metadata, $elements);
		push @sets, $set;
	}

	return @sets;
}

1;
