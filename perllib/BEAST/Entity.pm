#!/usr/bin/perl -w
#Author:	Evan Paull (epaull@soe.ucsc.edu)
#Create Date:	8.20.2010

use strict;
use warnings;
use lib "/projects/sysbio/map/Projects/BEAST/perllib";
use lib "/projects/sysbio/beast/perllib";

our $TRUE = 1;
our $FALSE = 0;

package Entity;

sub new
{
	my $class = shift;

	my $self;
	if (@_ >= 2) {
		my $name = shift;
		my $desc = shift;
		my $ex_id = shift;
		my $keyspace = shift;

		$self = {
			'_name' 	=> $name,
			'_desc'		=> $desc,
			'_ex_id'	=> $ex_id,
			'_keyspace'	=> $keyspace,
		};
	}

	bless $self, $class;
	return $self;
}

sub set_id
{
	my $self = shift;
	my $id = shift;

	$self->{'_id'} = $id;	
}

sub get_id
{
	my $self = shift;
	return $self->{'_id'};
}

sub set_membership_value
{
	my $self = shift;
	my $value = shift;

	$self->{'_membership_value'} = $value;
}

sub get_membership_value
{
	my $self = shift;

	if (defined $self->{'_membership_value'} && ($self->{'_membership_value'} =~ /.*\d+.*/) ) {
		return $self->{'_membership_value'};
	}

	# if undefined
	return 1;
}



sub get_name
{
	my $self = shift;
	return $self->{'_name'};
}
sub get_desc
{
	my $self = shift;
	return $self->{'_desc'};
}

sub get_ex_id
{
	my $self = shift;
	return $self->{'_ex_id'};
}

sub get_keyspace
{
	my $self = shift;
	return $self->{'_keyspace'};
}

sub escapeSQLString
{
	my $string = shift;

	$string =~ s/'/\\'/g; 
	$string =~ s/=/\\=/g; 
	$string =~ s/,/\\,/g; 

	return $string;
}

sub insertDB
{
	my $self = shift;
	my $db = shift;
	my $err_str = shift;

	my $internal_id;
	if (($internal_id = $db->existsEntity($self->get_ex_id, $self->get_keyspace)) > 0) {
		$$err_str = "entity already exists: ".$self->get_name." ".$self->get_ex_id;
	} else {
		my $desc = escapeSQLString($self->get_desc);
		$internal_id = $db->insertEntity($self->get_name, $desc, $self->get_ex_id, $self->get_keyspace);
		$$err_str = "added entity: ".$self->get_ex_id;
	}

	return $internal_id;
}

1;
