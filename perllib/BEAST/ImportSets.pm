#!/usr/bin/perl -w
#Author:	Evan Paull (epaull@soe.ucsc.edu)
#Create Date:	6.29.2010

use strict;
use warnings;
use lib "/projects/sysbio/map/Projects/BEAST/perllib";
use DBI;

use Data::Dumper;
use BEAST::Set;

package ImportSets;

# 
# Instance Methods:
#
# my $importer ImportSets->new;
# $importer->connectDB();
# $importer->importSet($set);
# $importer->disconnectDB();
#
# Static Methods:
#
# ImportSets::parseSetLines(@text_lines_from_import_file);
#
sub new
{
	my $class = shift;

	my $self = {
		'_db_name' 	=> 'BEAST_dev',
		'_hostname'	=> 'localhost',
		'_port'		=> '$port',
		'_username'	=> 'stuartLabMember',
		'_pass'		=> 'sysbio',
	};

	bless $self, $class;
	return $self;
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

#
# DB Connection must already be open before this function is called
#
sub importSetToDB($)
{
	my $self = shift;
	## Set class obj
	my $set = shift;

	my $sqlCommand;
	my $setnameinsert = "INSERT INTO ..".$set->get_name;

	foreach (@{$set->get_elements}) 
	{
		my $elem = $_;

	}

	## run SQL
	$self->runSQL($sqlCommand);
}

#
# DB Connection must already be open before this function is called
#
sub loadSetFromDB()
{
	my $self = shift;
	## Set class obj

	## populate these
	my $metadata = {};
	my $elements = {};

	my $sqlCommand;
	my $elements = "SELECT ..";
	## run SQL
	$self->runSQL($sqlCommand);
	## 
	

	my $name;
	my $set = Set->new($name, 1, $metadata, $elements);
	return $set;
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
	my $db_handle  = DBI->connect($dsn, $user, $pass) or die "Unable to connect $DBI::errstr\n";
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

sub insertSQL($$)
{
	my $self = shift;
	my($sql) = @_;

	$self->runSQL($sql);
	my $results = $self->runSQL("SELECT last_insert_id();");
	
	my (@data) = $results->fetchrow_array();

	# return the id of the newly created element
	return $data[0];
}

sub escapeSQLString
{
	my $string = shift;

	$string =~ s/'/\\'/g; 

	return $string;
}

# return the id created
sub insertSet($$)
{
	my $self = shift;
	my $name = shift;
	my $external_id = shift;

	my $template = "INSERT INTO sets (name, external_id) VALUES (var1, var2);";

	$name = escapeSQLString($name);

	$template =~ s/var1/'$name'/;
	$template =~ s/var2/'$external_id'/;

	return $self->insertSQL($template);	
}

# return the id created
sub insertMeta($$)
{
	my $self = shift;
	my ($external_id, $name) = @_;

	my $template = "INSERT INTO meta (external_id, name) VALUES (var1, var2);";

	$name = escapeSQLString($name);

	$template =~ s/var1/'$external_id'/;
	$template =~ s/var2/'$name'/;

	return $self->insertSQL($template);	
}

# return the id created
sub insertEntity($$$$)
{
	my $self = shift;
	my ($name, $desc, $key, $keyspace) = @_;

	my $template = "INSERT INTO entity (name, description, entity_key, keyspace_id) VALUES (var1, var2, var3, var4);";

	$name = escapeSQLString($name);
	$desc = escapeSQLString($desc);

	$template =~ s/var1/'$name'/;
	$template =~ s/var2/'$desc'/;
	$template =~ s/var3/'$key'/;
	$template =~ s/var4/'$keyspace'/;

	return $self->insertSQL($template);	
}

sub insertSetEntityRel($$$)
{
	my $self = shift;
	my ($set_id, $entity_id, $membership_value) = @_;

	my $template = "INSERT INTO set_entity (sets_id, entity_id, member_value) VALUES (var1, var2, var3);";
	
	$template =~ s/var1/'$set_id'/;
	$template =~ s/var2/'$entity_id'/;
	if ($membership_value eq "NULL") {
		$template =~ s/var3/NULL/;
	} else {
		$template =~ s/var3/'$membership_value'/;
	}

	$self->runSQL($template);	
}

sub insertMetaMetaRel($$$)
{
	my $self = shift;
	my ($parent, $set_child, $meta_child) = @_;

	my $template = "INSERT INTO meta_sets (sets_meta_id, sets_id, meta_meta_id) VALUES (var1, var2, var3);";
	
	$template =~ s/var1/'$parent'/;
	if ($set_child eq "NULL") {
		$template =~ s/var2/$set_child/;
	} else {
		$template =~ s/var2/'$set_child'/;
	}
	if ($meta_child eq "NULL") {
		$template =~ s/var3/$meta_child/;
	} else {
		$template =~ s/var3/'$meta_child'/;
	}
	$self->runSQL($template);	
}


1;
