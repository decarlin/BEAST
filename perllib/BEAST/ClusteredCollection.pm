#!/usr/bin/perl -w
#Author:	Evan Paull (epaull@soe.ucsc.edu)
#Create Date:	6.16.2010

use strict;
use warnings;
use lib "/projects/sysbio/map/Projects/BEAST/perllib";
# JSON object serialization
use BEAST::Set;
use BEAST::Collection;
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
	my $new_cluster = shift;

	die unless (ref($new_cluster) eq 'Set');

	$self->{'cluster'} = $new_cluster;

	# now redo the order of the sets
	my @leaves = $new_cluster->getLeafNodes;
	$self->{'sets'} = [];
	foreach my $leaf (@leaves) {

		# we're not saving the sets here -- just pointing to the names
		push @{$self->{'sets'}}, $leaf->get_name;
  	}
}

sub get_cluster
{
	my $self = shift;

	return $self->{'cluster'};
}


1;
