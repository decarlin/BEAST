#!/usr/bin/perl -w
#Author:	Evan Paull (epaull@soe.ucsc.edu)
#Create Date:	6.16.2010

use strict;
use warnings;
use lib "/projects/sysbio/map/Projects/BEAST/perllib";
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
	# hash ref
	my $constructor_mode = shift;
	my $self = {};
	
	if ($constructor_mode eq 'sets') {
		my @sets = @_;
		$self->{'sets'} = [];
		foreach (@sets) {
			my $set = $_;
			die unless (ref($set) eq 'Set');

			# we're not saving the sets here -- just pointing to the names
			push @{$self->{'sets'}}, $set->get_name;
	  	}
	} elsif ($constructor_mode eq 'json') {

		my $json_text = shift;
		my $json = JSON->new->utf8;
		$self = $json->decode($json_text);

	} elsif ($constructor_mode eq 'names') {
		my @names = @_;
		$self->{'sets'} = [];
		foreach (@names) {
			# we're not saving the sets here -- just pointing to the names
			push @{$self->{'sets'}}, $_;
	  	}
	} else {
		die "Collection::new method called with unknown mode!";
	}

	bless $self, $class;
	return $self;
}


sub serialize
{
	my $self = shift;

	my $json = JSON->new->utf8;
	$json = $json->convert_blessed([1]);
	return $json->encode($self);
}

1;
