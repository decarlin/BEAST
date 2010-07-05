#!/usr/bin/perl -w
#Author:	Evan Paull (epaull@soe.ucsc.edu)
#Create Date:	6.29.2010

use strict;
use warnings;
use lib "/projects/sysbio/map/Projects/BEAST/perllib";
use DBI;

use Data::Dumper;
use BEAST::Set;
use BEAST::BeastDB;

our $TRUE = 1;
our $FALSE = 0;

package Search;

# 
# Instance Methods:
#
# Static Methods:
#
# DataBase Specifications:
# 
# 	The DB has set elements, meta elements and entity's.
# 	It is assumed that each set's immediate parents are always
# 	the most specific heirarchy 
#
#
sub new
{
	my $class = shift;
	my $dbh = shift;

	my $self = {
		'_beast_db' => $dbh,
	};

	bless $self, $class;
	return $self;
}


sub findParentsForSetByExtID($)
{
	my $self = shift;
	my $ext_id = shift;

	my $beastDB = $self->{'_beast_db'};
	my $set_id = $beastDB->getSetIdFromExternalId($ext_id);
	unless ($set_id =~ /\d+/) { return $FALSE; }

	return $self->findParentsForSet($set_id);	
}

#
# Build the meta heirarchy from the bottom up:
# start with the leaf (the set) and find all it's parents
#
sub findParentsForSet($)
{
	my $self = shift;
	my $set_id = shift;

	# database object
	my $beastDB = $self->{'_beast_db'};
	# immediate parents, should all be meta.id's
	my @set_parents = $beastDB->getParentsForSet($set_id);	

	if ($#set_parents == -1) {
		return $FALSE;
	}

	# create the set object, and assign it to a 'elements' hash reference, 
	# which each meta parent will point to 
	my ($set_name, $set_ext_id) = $beastDB->getSetNameExtIdFromID($set_id);
	my $set_metadata = { 'type' => 'set', 'name' => "$set_name", 'id' => $set_id };
	my $set_elements = {};
	my $set = Set->new($set_ext_id, 1, $set_metadata, $set_elements);
	my $metadata_element = { "$set_ext_id" => $set };

	my @set_parent_objs;
	foreach (@set_parents) {
		my $meta_id = $_;
		my ($meta_name, $ext_id) = $beastDB->getMetaNameExtIDFromID($meta_id);
		my $metadata = { 'type' => 'meta', 'name' => "$meta_name", 'id' => $meta_id };
		my $meta_set = Set->new($ext_id, 1, $metadata, $metadata_element);

		push @set_parent_objs, $meta_set;
	}

	## these are the top nodes that contain a data structure below
	my @top_level_nodes = $self->findParentsForMetas(@set_parent_objs);

	return @top_level_nodes;
}

sub findParentsForMetas
{
	my $self = shift;
	my @children = @_;

	my @collective_parents;
	# database object
	my $beastDB = $self->{'_beast_db'};
	# immediate parents, should all be meta.id's

	my $collective_parents = {};

	my $found_parents = 0;
	foreach (@children) {
		my $child = $_;
		my $child_id = $child->get_metadata_value('id');
		my $child_ext_id = $child->get_name;
		# now we've got a set of parents for this child, but 
		# some of those same parents may have already been found
		# by a sibling, and are stored in the $collective_parents hash
		my @my_parents = $beastDB->getParentsForMeta($child_id);	
		if ($#my_parents == -1) {
			# what to do if this child has no parents, but one or more of
			# it's siblings do?
			next;
		}
		$found_parents++;

		foreach (@my_parents) { 
			my $parent_id = $_;
			# if we've found a parent, add ourselves to it's pointer and continue
			if (exists $collective_parents->{$parent_id}) {
				my $parent = $collective_parents->{$parent_id};
				$parent->set_element($child_ext_id, $child);
			} else {
			# otherwise create a new set object as that parent, and add it to the collective parents list
				my ($parent_name, $parent_ext_id) = $beastDB->getMetaNameExtIDFromID($parent_id);

				# create the parent object and add this child as one of its elements
				my $elements = { "$child_ext_id" => $child };
			        my $metadata = { 'type' => 'meta', 'name' => "$parent_name", 'id' => $parent_id };
				my $parent = Set->new($parent_ext_id, 1, $metadata, $elements);
				$collective_parents->{$parent_ext_id} = $parent;
			}
		}
	
	}

	# if we're at the top level, return the set entity's
	if ($found_parents == 0) {
		return @children;
	} else {
	# otherwise recurse upwards
		foreach (keys %$collective_parents) {
			push @collective_parents, $collective_parents->{$_};
		}
		return $self->findParentsForMetas(@collective_parents);
	}
}


#
# Find a place where they differ, then add the second tree's subsets to the first 
# tree's subsets
#
sub mergeTrees($$)
{
	my $tree1 = shift;
	my $tree2 = shift;

	my @children_of_1 = $tree1->get_element_names;
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
		if ($found == $FALSE) {
			my $element = $tree2->get_element($child);
			$tree1->set_element($child, $element); 
		} else {
		# otherwise they both have the same node -- merge the subnodes
			mergeTrees($tree1->get_element($child), $tree2->get_element($child));	
		}
	}
}


1;
