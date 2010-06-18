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

sub new
{
	my $class = shift;
	# hash ref
	my $name = shift;
	my $metadata = shift;
	my $elements = shift;

	my $self = {
		'_name' 	=> $name,
	 	'_metadata' 	=> $metadata,
		#'_metadata' 	=> { 'key2 => 'value1',
		# 		     'key2 => 'value2
		'_elements'	=> $elements,
		# '_elements'	=> { 'name' 	=>  $setObj1,
		#		     'name2' 	=>  $setObj2


		
	};

	bless $self, $class;
	return $self;
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

	unless (exists($self->{'_elements'}->{$element_name})) { return $FALSE; }
	return ($TRUE, $self->{'_elements'}->{$element_name});
}

sub get_element_names
{
	my $self = shift;

	return (keys %{$self->{'_elements'}});	
}

1;
