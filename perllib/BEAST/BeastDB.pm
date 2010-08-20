#!/usr/local/bin/perl -w
#Author:	Evan Paull (epaull@soe.ucsc.edu)
#Create Date:	6.29.2010

use strict;
use warnings;
use lib "/projects/sysbio/map/Projects/BEAST/perllib";
# DBI + DBD installation
use DBI;

use Data::Dumper;
use BEAST::Set;

package BeastDB;


our $TRUE=1;
our $FALSE=0;



sub importSetToDB($);
sub connectDB();
sub disconnectDB();
sub runSQL($$);
sub getSetIdFromExternalId($);
sub getSetNameExtIdFromID($);
sub getEntityNameFromID($);
sub getMetaIdFromExternalId($);
sub getMetaNameExtIDFromID($);
sub insertSQL($$);
sub escapeSQLString;
sub insertSet($$);
sub insertMeta($$);
sub insertEntity($$$$);
sub insertSetEntityRel($$$);
sub insertMetaMetaRel($$);
sub insertSetMetaRel($$);
sub existsMetaMetaRel($$);
sub existsSetMetaRel($$);
sub existsSetEntityRel($$);
sub getParentsForSet($$);
sub getEntitiesForSet($$);
sub searchSetsByTermRestrictKeyspace($$$);
sub searchSetsByTerm($);
sub getParentsForMeta($$);
sub existsMeta($$);
sub existsSet($$);
sub existsEntity($$);
sub findRoots();
sub getRoots();
sub getChildren($);


# 
# Instance Methods:
#
# $beastDB->connectDB();
# $beastDB->importSet($set);
# $beastDB->disconnectDB();
#
#
sub new
{
	my $class = shift;
	my $dev = shift || undef;

	my $self;
	if ((defined $dev) && ($dev eq 'dev')) {
		$self = {
		'_db_name' 	=> 'BEAST_dev',
		'_hostname'	=> 'localhost',
		'_port'		=> '3306',
		'_username'	=> 'stuartLabMember',
		'_pass'		=> 'sysbio',
		};
	} elsif ((defined $dev) && ($dev eq 'test')) {
		$self = {
		'_db_name' 	=> 'BEAST_test',
		'_hostname'	=> 'localhost',
		'_port'		=> '3306',
		'_username'	=> 'stuartLabMember',
		'_pass'		=> 'sysbio',
		};
	} else {
		$self = {
		'_db_name' 	=> 'BEAST_dev',
		'_hostname'	=> 'disco.cse.ucsc.edu',
		'_port'		=> '3306',
		'_username'	=> 'beast_user',
		'_pass'		=> 'beast_guest',
		};
	}

	bless $self, $class;
	return $self;
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

sub getSetIdFromExternalId($)
{
	my $self = shift;
	my $external_id = shift;
	
	$external_id = escapeSQLString($external_id);

	my $results = $self->runSQL("SELECT id FROM sets WHERE external_id='".$external_id."'");	

	my (@data) = $results->fetchrow_array();
	return $data[0];
}

sub getSetNameExtIdFromID($)
{
	my $self = shift;
	my $set_id = shift;
	
	die unless ($set_id =~ /\d+/);	

	my $results = $self->runSQL("SELECT name,external_id FROM sets WHERE id='".$set_id."'");	

	my (@data) = $results->fetchrow_array();
	return ($data[0], $data[1]);
}

sub getEntityNameFromID($)
{
	my $self = shift;
	my $id = shift;

	die unless ($id =~ /\d+/);	

	my $results = $self->runSQL("SELECT name FROM entity WHERE id='".$id."'");	

	my (@data) = $results->fetchrow_array();
	return $data[0];
}

#
# Return meta.id integer value, from the external ID
#
sub getMetaIdFromExternalId($)
{
	my $self = shift;
	my $external_id = shift;
	
	$external_id = escapeSQLString($external_id);

	my $results = $self->runSQL("SELECT id FROM meta WHERE external_id='".$external_id."'");	

	my (@data) = $results->fetchrow_array();
	return $data[0];
}

sub getMetaNameExtIDFromID($)
{
	my $self = shift;
	my $meta_id = shift;
	
	my $results = $self->runSQL("SELECT name, external_id FROM meta WHERE id='".$meta_id."'");	

	my (@data) = $results->fetchrow_array();
	return ($data[0], $data[1]);
}

#
# Wrapper for SQL statement to get the id of the last insert
#
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

##
## Functions for Table inserts
##

# return the id created
sub insertSet($$)
{
	my $self = shift;
	my $name = shift;
	my $external_id = shift;

	die if (scalar(@_) > 2);

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

##
## DB Functions for Relation mapping inserts
##

sub insertSetEntityRel($$$)
{
	my $self = shift;
	my ($set_id, $entity_id, $membership_value) = @_;

	die if (scalar(@_) > 3);

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

sub insertMetaMetaRel($$)
{
	my $self = shift;
	my ($parent, $meta_child) = @_;

	die if (scalar(@_) > 2);

	my $template = "INSERT INTO meta_sets (sets_meta_id, sets_id, meta_meta_id) VALUES (var1, NULL, var2);";
	
	$template =~ s/var1/'$parent'/;
	$template =~ s/var2/'$meta_child'/;
	$self->runSQL($template);	
}

sub insertSetMetaRel($$)
{
	my $self = shift;
	my ($parent, $set_child) = @_;

	die if (scalar(@_) > 2);

	my $template = "INSERT INTO meta_sets (sets_meta_id, sets_id, meta_meta_id) VALUES (var1, var2, NULL);";
	
	$template =~ s/var1/'$parent'/;
	$template =~ s/var2/'$set_child'/;
	$self->runSQL($template);	
}

sub existsMetaMetaRel($$)
{
	my $self = shift;
	my ($parent, $meta_child) = @_;

	die if (scalar(@_) > 2);

	my $query = "SELECT * FROM meta_sets WHERE sets_meta_id=var1 AND meta_meta_id=var3";

	$query =~ s/var1/'$parent'/;
	$query =~ s/var3/'$meta_child'/;

	my $results = $self->runSQL($query);	
	my (@data) = $results->fetchrow_array();
	if ($#data == -1) {
		return $FALSE;
	} else {
		return $TRUE;
	}
}

sub existsSetMetaRel($$)
{
	my $self = shift;
	my ($parent, $set_child) = @_;
	die if (scalar(@_) > 2);

	my $query = "SELECT * FROM meta_sets WHERE sets_meta_id=var1 AND sets_id=var2";

	$query =~ s/var1/'$parent'/;
	$query =~ s/var2/'$set_child'/;

	my $results = $self->runSQL($query);	
	my (@data) = $results->fetchrow_array();
	if ($#data == -1) {
		return $FALSE;
	} else {
		return $TRUE;
	}
}

sub existsSetEntityRel($$)
{
	my $self = shift;
	my ($set_id, $entity_id) = @_;

	die if (scalar(@_) > 2);

	my $template = "SELECT * FROM set_entity WHERE sets_id=var1 AND entity_id=var2";
	
	$template =~ s/var1/'$set_id'/;
	$template =~ s/var2/'$entity_id'/;

	my $results = $self->runSQL($template);	
	my (@data) = $results->fetchrow_array();
	if ($#data == -1) {
		return $FALSE;
	} else {
		return $TRUE;
	}
}

##
## Parent search functions
##
sub getParentsForSet($$)
{
	my $self = shift;
	my $set_id = shift;

	my $template = "SELECT sets_meta_id FROM meta_sets WHERE sets_id='var1';";

	$template =~ s/var1/$set_id/;

	my $results = $self->runSQL($template);
	my (@data) = $results->fetchrow_array();
	return @data;
}

sub getEntitiesForSet($$)
{
	my $self = shift;
	my $set_id = shift;

	my $template = "SELECT entity_id,member_value FROM set_entity WHERE sets_id='var1';";

	$template =~ s/var1/$set_id/;

	my $results = $self->runSQL($template);
	my $rows_ref = $results->fetchall_arrayref();
	my $ids_values = {};
	if (ref($rows_ref) eq 'ARRAY') {
		foreach (@$rows_ref) {
			my ($id, $value) = ($_->[0], $_->[1]);
			$ids_values->{$id} = $value;
		}
	}

	my $names_values = {};
	foreach (keys %$ids_values) {
		my $id = $_;
		my $name = $self->getEntityNameFromID($id);
		my $member_value = $ids_values->{$id};
		$names_values->{uc($name)} = $member_value;
	}
	return $names_values;
}

# sets -> keyspace.organism='blah'
# 	  keyspace.source='bleh'
# 	  keyspace.description='bleh'
# 	  keyspace.created='bleh'
# This is a big join: might be slow before it's cached
# sub searchSetsByTermRestrictKeyspace(text, keyspace field, keyspace value)
#
# Note: the current implementation restricts to sets that actually have entities 
#
sub searchSetsByTermRestrictKeyspace($$$)
{
	my $self = shift;
	my $search_text = shift;
	# hash ref
	my $opts = shift;
	# current fields

	$search_text = escapeSQLString($search_text);

	my $template .= " SELECT sets.id FROM sets ";
	$template .= "JOIN set_entity ON sets.id = set_entity.sets_id ";
	$template .= "JOIN sets_info ON sets.id = sets_info.sets_id ";
	$template .= "JOIN entity ON set_entity.entity_id = entity.id ";
	$template .= "JOIN keyspace ON entity.keyspace_id = keyspace.id";

	my $j = 0;
	$template = $template." WHERE ";
	foreach (keys %{$opts->{'keyspace'}}) 
	{
		if ($j != 0) 
		{
			$template = $template." AND ";
		}
		$j++;
		my $key = $_;
		my @values = @{$opts->{'keyspace'}->{$key}};
		
		$template = $template." ( keyspace.".$key." = '".$values[0]."' ";
		for my $i (1 .. $#values) 
		{
			$template = $template." OR keyspace.".$key." = '".$values[$i]."' ";
		}
		$template = $template.") ";
	}
	$template = $template."AND sets.name LIKE '%".$search_text."%'";

	# add the set info...
	foreach (keys %{$opts->{'sets_info'}}) {
		my $key = $_;
		my @values = @{$opts->{'sets_info'}->{$key}};
		next if (scalar(@values) == 0);
		$template .= " AND sets_info.name='".$key."' AND (";		
		for my $i (0 .. ($#values - 1)) {
			$template .= "sets_info.value='".$values[$i]."' OR ";		
		}
		$template .= "sets_info.value='".$values[-1]."')";
	}
	# debug
	#print $template;

	my $results = $self->runSQL($template);

	my @data;
	my $tbl_array_ref = $results->fetchall_arrayref([0]);
	foreach (@$tbl_array_ref) {
		my $array_ref = $_;
		push @data, $array_ref->[0];
	}

	return @data;
}

# restrict to non-empty sets that have real entities attached
sub searchSetsByTerm($)
{
	my $self = shift;
	my $opts = shift;
	my ($search_text) = @_;

	my $template = "SELECT DISTINCT sets.id FROM sets,set_entity,sets_info WHERE sets.id=set_entity.sets_id AND sets.id=sets_info.sets_id AND sets.name LIKE '%var1%'";

	$search_text = escapeSQLString($search_text);
	$template =~ s/var1/$search_text/;

	# add the set info...
	foreach my $key (keys %{$opts->{'sets_info'}}) {
		my @values = @{$opts->{'sets_info'}->{$key}};
		next if (scalar(@values) == 0);
		$template .= " AND sets_info.name='".$key."' AND (";		
		for my $i (0 .. ($#values - 1)) {
			$template .= "sets_info.value='".$values[$i]."' OR ";		
		}
		$template .= "sets_info.value='".$values[-1]."')";
	}

	my $results = $self->runSQL($template);

	my @data;
	my $tbl_array_ref = $results->fetchall_arrayref([0]);
	foreach (@$tbl_array_ref) {
		my $array_ref = $_;
		push @data, $array_ref->[0];
	}

	return @data;
}

sub getParentsForMeta($$)
{
	my $self = shift;
	my ($meta_id) = @_;

	my $template = "SELECT sets_meta_id FROM meta_sets WHERE meta_meta_id='var1';";

	$template =~ s/var1/$meta_id/;

	my $results = $self->runSQL($template);
	my (@data) = $results->fetchrow_array();
	return @data;
}

sub existsMeta($$)
{
	my $self = shift;
	my ($ex_id) = @_;

	my $template = "SELECT id FROM meta WHERE external_id='var1';";

	$template =~ s/var1/$ex_id/;

	my $results = $self->runSQL($template);
	my (@data) = $results->fetchrow_array();
	if ($#data == -1) {
		return $FALSE;
	} else {
		return $data[0];
	}
}

sub existsSet($$)
{
	my $self = shift;
	my ($ex_id) = @_;

	my $template = "SELECT id FROM sets WHERE external_id='var1';";

	$template =~ s/var1/$ex_id/;

	my $results = $self->runSQL($template);
	my (@data) = $results->fetchrow_array();
	if ($#data == -1) {
		return $FALSE;
	} else {
		return $data[0];
	}
}


sub existsEntity($$)
{
	my $self = shift;
	my ($ex_id, $keyspace) = @_;

	my $template = "SELECT id FROM entity WHERE entity_key='var1' AND keyspace_id='var2'";

	$template =~ s/var1/$ex_id/;
	$template =~ s/var2/$keyspace/;

	my $results = $self->runSQL($template);
	my (@data) = $results->fetchrow_array();
	if ($#data == -1) {
		return $FALSE;
	} else {
		return $data[0];
	}
}


sub findRoots()
{
	my $self = shift;

	my $sql = "SELECT m.id, m.name, m.external_id FROM meta m LEFT OUTER JOIN meta_sets ms ON ms.meta_meta_id=m.id WHERE ms.sets_meta_id IS NULL;";
	my %roots;
	
	my $results = $self->runSQL($sql);
	while (my(@data) = $results->fetchrow_array())
	{
		my $id = $data[0];
		my $name = $data[1];
		my $external_id = $data[2];
		$roots{$id}{'id'} = $id;
		$roots{$id}{'name'} = $name;
		$roots{$id}{'external_id'} = $external_id;
	}
	return \%roots;
}


sub getRoots()
{
	my $self = shift;
	my $sql = "SELECT id, name, external_id FROM roots r, meta m WHERE r.meta_id=m.id;";

	my %roots;
	
	my $results = $self->runSQL($sql);
	while (my(@data) = $results->fetchrow_array())
	{
		my $id = $data[0];
		my $name = $data[1];
		my $external_id = $data[2];
		$roots{$name.$id}{'id'} = $id;
		$roots{$name.$id}{'name'} = $name;
		$roots{$name.$id}{'external_id'} = $external_id;
	}
	return \%roots;
}

sub getChildren($)
{
	my $self = shift;
	my ($parent_id) = @_;
	
	#get metas
	my $sql = "SELECT m.id, m.name, m.external_id FROM meta m JOIN meta_sets ms ON ms.meta_meta_id=m.id WHERE ms.sets_meta_id='$parent_id';";
	my %children;
	
	my $results = $self->runSQL($sql);
	while (my(@data) = $results->fetchrow_array())
	{
		my $id = $data[0];
		my $name = $data[1];
		my $external_id = $data[2];
		#key on $name.$id purely for sorting purposes.  this needs to be unique, so should include id, but could be sorted by id, externa_id, or name
		$children{'meta'}{$name.$id}{'id'} = $id;
		$children{'meta'}{$name.$id}{'name'} = $name;
		$children{'meta'}{$name.$id}{'external_id'} = $external_id;
	}
	
	#get sets
	$sql = "SELECT s.id, s.name, s.external_id FROM sets s JOIN meta_sets ms ON ms.sets_id=s.id WHERE ms.sets_meta_id='$parent_id';";
	
	$results = $self->runSQL($sql);
	while (my(@data) = $results->fetchrow_array())
	{
		my $id = $data[0];
		my $name = $data[1];
		my $external_id = $data[2];
		#key on $name.$id purely for sorting purposes.  this needs to be unique, so should include id, but could be sorted by id, externa_id, or name
		$children{'set'}{$name.$id}{'id'} = $id;
		$children{'set'}{$name.$id}{'name'} = $name;
		$children{'set'}{$name.$id}{'external_id'} = $external_id;
	}
	return \%children;
}

1;
