#!/usr/bin/perl -w
#Author:	Evan Paull (epaull@soe.ucsc.edu)
#Create Date:	6.16.2010

use strict;
use warnings;
use lib "/projects/sysbio/map/Projects/BEAST/perllib";
use DBI;

package BEAST::ImportSets;

sub new
{
	my $class = shift;

	my $self = {
		'_db_name' 	=> 'BEAST_dev',
		'_hostname'	=> 'localhost',
		'_port'		=> '$port',
		'_username'	=> 'stuartLabMember',
		'_pass'		=> '',
	};

	bless $self, $class;
	return $self;
}

sub importSetsToDB
{
	my $self = shift;
	my @sets = @_;

	$self->connectDB();
	foreach (@sets) 
	{
		my $set = {};
		my @components = split(/:/, $_);
		my $query = "";
		$set->{'name'} = $components[0];
		my @elements;
		my @metadata;
		foreach (@components) 
		{
			my $component = $_;
			# metadata goes in with key/value pairs
			if ($component =~ /=)/) {
				push @metadata, $component;
			} else {
				push @elements, $component;	
			}
		}
		$set->{'elements'} = [ @elements ];
		$set->{'metadata'} = [ @metadata ];

		$self->importSetToDB($set);
	}
	$self->disconnectDB();
}

sub importSetToDB($)
{
	my $self = shift;
	my $set = shift;

	my $setnameinsert = "INSERT INTO $set->{'name'}";
	my $name = $set->{'name'};

	## run SQL
}

sub connectDB()
{
	my $self = shift;

	my $database = $self->{'_db_name'};
	my $hostname = $self->{'_hostname'};
	my $port = $self->{'_port'};
	my $user = $self->{'_username'};
	my $pass = $self->{'_pass'};
	my $dsn = "DBI:mysql:database=$database;host=$hostname;port=$port";
	my $db_handle  = DBI->connect($dsn, $user, $password) or die "Unable to connect $DBI::errstr\n";
	$self->{'_db_handle'} = $db_handle;
}

sub disconnectDB()
{
	my $self = shift;

	$self->{'_db_handle'}->disconnect or die "Failed to disconnect DBH!";
}

sub runSQL($$)
{
	my $self = shift;
	my($sql) = @_;

	my $db_handle = $self->{'_db_handle'};
	my($statement) = $db_handle->prepare($sql) or die "Couldn't prepare query '$sql': $DBI::errstr\n";
	$statement->execute() or die "Couldn't execute query '$sql': $DBI::errstr\n";
    
	return $statement;
}

