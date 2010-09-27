#!/usr/bin/perl -w
#Author:	Evan Paull (epaull@soe.ucsc.edu)
#Create Date:	6.16.2010

use strict;
use warnings;
use lib "/projects/sysbio/map/Projects/BEAST/perllib";
use lib "/var/www/cgi-bin/BEAST/perllib";
# JSON object serialization
use BEAST::Set;
use JSON -convert_blessed_universally;

our $TRUE = 1;
our $FALSE = 0;

package Collection;

# stores an ordered list of set names -- but not the 
# set data 

sub new
{
	my $class = shift;
	if (ref($class) eq 'Collection') { 
		$class = 'Collection';
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

sub get_name
{
	my $self = shift;
	return $self->{'_name'};
}

sub get_set_names
{
	my $self = shift;
	return @{$self->{'sets'}};
}

# assuming homosets, the source sets_info of the sets
sub get_source
{
	my $self = shift;
	return $self->{'source'};
}

sub get_keyspace_organism
{
	my $self = shift;
	return $self->{'keyspace_organism'};
}

sub get_keyspace_source
{
	my $self = shift;
	return $self->{'keyspace_source'};
}

sub set_source
{
	my $self = shift;
	my $source = shift;

	$self->{'source'} = $source;
}

sub set_keyspace_organism
{
	my $self = shift;
	my $keysp_organism = shift;

	$self->{'keyspace_organism'} = $keysp_organism;
}

sub set_keyspace_source
{
	my $self = shift;
	my $keysp_source = shift;

	$self->{'keyspace_source'} = $keysp_source;
}

sub serialize
{
	my $self = shift;

	my $json = JSON->new->utf8;
	$json = $json->convert_blessed([1]);
	return $json->encode($self);
}

1;
