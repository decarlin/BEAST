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
		$str = $str."\t".$_;
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
		next unless ($line =~ /\S+\s+/);
		my @components = split(/\^/, $line);

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
			} else {
				# tab delineated elements
				foreach (split(/\s+/, $component)) {
					next unless ($_ =~ /\S+/);
					$elements->{$_} = 1;	
				}
			}
		}

		my $set = Set->new($name, 1, $metadata, $elements);
		push @sets, $set;
	}

	return @sets;
}

1;
