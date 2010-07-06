#!/usr/bin/perl -w
#Author:	Evan Paull (epaull@soe.ucsc.edu)
#Create Date:	6.16.2010

use strict;
use warnings;
use lib "/projects/sysbio/map/Projects/BEAST/perllib";
use DBI;

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
	my $name = shift;
	my $active = shift;
	my $metadata = shift;
	my $elements = shift;

	my $self = {
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

	bless $self, $class;
	return $self;
}

sub serialize
{
	my $self = shift;
	
	my $str = $self->{'_name'}.$self->{'_delim'};
	foreach (keys %{$self->{'_metadata'}}) {
		$str = $str.$_."=".$self->{'_metadata'}->{$_}.$self->{'_delim'};
	}
	foreach (keys %{$self->{'_elements'}}) {
	
		my $name = $_;
		my $element = $self->get_element($_);
		if (ref($element) eq 'Set') {
			$str = $str."\t"."[ ";
			$str = $str.$element->serialize();
			$str = $str." ]";
		} else {
			$str = $str."\t".$name;
		}
	}

	return $str;
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
# Parse Lines, return set objects
#
sub parseSetLines
{
	my @lines = @_;

	my @sets;


	foreach (@lines) 
	{
		my $line = $_;
		chomp($line);
		next unless ($line =~ /\S+\s+/);
		$line =~ /(\S+)\^\t(.*)/;
		my @components = split (/\^/,$1);
		my $subsets = $2;

		## create a set object
		my $name = $components[0];
		my $metadata = {};
		my $elements = {};
		my $i = 0;

		for (@components) 
		{
			# the first element is the name
			if ($i == 0) { $i++; next; }

			my $component = $_;
			# metadata goes in with key/value pairs
			if ($component =~ /(.*)=(.*)/) {
				$metadata->{$1} = $2;
			} 
		}


		# tab delineated elements
		my $parse_state = 0;
		my $parse_string = "";
		foreach (split(/\t/, $subsets)) {
			my $part = $_;
			if ($part =~ /\[/) {
				if ($parse_state == 0) {
					$parse_string = $part;
				} else {	
					$parse_string = $parse_string."\t".$part;
				}
				$parse_state++;
				next;
			} elsif ($part =~ /\]/) {
				$parse_state--;
			        $parse_string = $parse_string."\t".$part;
				if ($parse_state == 0) {
				  $parse_string =~ /^\[ (.*) \]$/;
			  	  my @ln = ($1);
			  	  my @setS = parseSetLines(@ln); 
				  my $setname = $setS[0]->get_name;
			  	  $elements->{$setname} = $setS[0];	
				  $parse_string = "";
				}
				next;
			} elsif ($parse_state > 0) {
			        $parse_string = $parse_string."\t".$part;
				next;
			}

			# else 
		   	$elements->{$part} = 1;	
		}

		my $set = Set->new($name, 1, $metadata, $elements);
		push @sets, $set;
	}

	return @sets;
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


1;
