#!/usr/bin/perl -w
#Author:	Evan Paull (epaull@soe.ucsc.edu)
#Create Date:	6.16.2010

use strict;
use warnings;
use lib "/projects/sysbio/map/Projects/BEAST/perllib";
use DBI;

use Data::Dumper;
use BEAST::Set;
use BEAST::Constants;

use JSON -convert_blessed_universally;

package BeastSession;

sub saveObjsToSession
{
	my $session = shift;
	my $key = shift;
	my @objs = @_;

	die unless (ref($session) eq 'CGI::Session');
	die unless (ref($objs[0]));

	my $str;
	my $i = 0;
	foreach my $obj (@objs) {
		if ($i == 0) {
			$str = $obj->serialize();
		} else {
			my $tmp = $obj->serialize();
			$str = $str.":SEP:".$tmp;
		}
		$i++;
	}

	$session->param($key, $str);
}

sub saveGifInfoToSession
{
	my $session = shift;
	my $json_string = shift;

	die unless (ref($session) eq 'CGI::Session');

	$session->param('heatmap_info', $json_string);
}

sub getHeatmapInfoFromSession
{
	my $session = shift;

	die unless (ref($session) eq 'CGI::Session');

	my $json_string = $session->param('heatmap_info');

	my $json = JSON->new->utf8;
	my $jsonObj = $json->decode($json_string);
	return $jsonObj;
}

# selected is a hash ref of
# names of selected columns
# 
sub saveSelectedColumns
{
	my $session = shift;
	my $selected = shift;

	die unless (ref($session) eq 'CGI::Session');

	my $json_string = $session->param('heatmap_info');

	my $json = JSON->new->utf8;
	my $jsonObj = $json->decode($json_string);

	$jsonObj->{'selected_columns'} = $selected;

	$session->param('heatmap_info', $json->encode($jsonObj));
}

sub getSelectedColumns
{
	my $session = shift;

	die unless (ref($session) eq 'CGI::Session');

	my $json_string = $session->param('heatmap_info');
	if (!$json_string || $json_string eq "") { return ""; }

	my $json = JSON->new->utf8;
	my $jsonObj = $json->decode($json_string);

	my $selected = $jsonObj->{'selected_columns'};

	if (!$selected || $selected eq "") { return ""; }

	return $selected;
}

sub buildCheckedHash
{
	my @checked_sets = @_;

	my $hash = {};
	my $delim = Constants::SET_NAME_DELIM;
	foreach (@checked_sets) {
		my @parts = split(/$delim/, $_);
		$hash->{$parts[-1]} = 1;	
	}
	
	return $hash;
}

#
# Return: [ retval(0|1), @sets ]
#
sub loadMergeSetsFromSession($$$)
{
	my $session = shift;
	my $key = shift;
	my $checkbox_arr_ref = shift;

	die unless (ref($checkbox_arr_ref) eq 'ARRAY');
	die unless (ref($session) eq 'CGI::Session');
	die unless ($key =~ /^\w+$/);

	my $setsstr = $session->param($key);	
	my @lines = split (/:SEP:/, $setsstr);

	my @sets;
	foreach (@lines) {
		push @sets, Set->new($_);
	}

	my $checked_hash = buildCheckedHash(@$checkbox_arr_ref);
	my @selected_sets = mergeWithCheckbox(\@sets, $checked_hash);

	return @selected_sets;
}
#
# Return: [ retval(0|1), @sets ]
#
sub loadMergeLeafSets
{
	my $session = shift;
	my $key = shift;
	my $checkbox_arr_ref = shift;
	my $load_elements = shift || 0;

	die unless (ref($checkbox_arr_ref) eq 'ARRAY');
	die unless (ref($session) eq 'CGI::Session');
	die unless ($key =~ /^\w+$/);

	my $element_opts = {'external_id' => 1};
	my @sets = loadLeafSetsFromSession($session, $key, 1, $load_elements, $element_opts);

	my $checked_hash = buildCheckedHash(@$checkbox_arr_ref);
	my @selected_sets = mergeWithCheckbox(\@sets, $checked_hash);

	return @selected_sets;
}

sub loadMergeLeafSetsValues
{
	my $session = shift;
	my $key = shift;
	my $checkbox_arr_ref = shift;
	my $load_elements = shift || 0;

	die unless (ref($checkbox_arr_ref) eq 'ARRAY');
	die unless (ref($session) eq 'CGI::Session');
	die unless ($key =~ /^\w+$/);

	my @sets = loadLeafSetsFromSession($session, $key, 1, $load_elements, undef);

	my $checked_hash = buildCheckedHash(@$checkbox_arr_ref);
	my @selected_sets = mergeWithCheckbox(\@sets, $checked_hash);

	return @selected_sets;
}

sub saveSelectedCollections
{
	my $session = shift;
	my $selectedX = shift;
	my $selectedY = shift;

	$session->param('collectionX', $selectedX);
	$session->param('collectionY', $selectedY);
}

sub getSelectedCollectionNames
{
	my $session = shift;

	return ($session->param('collectionX'), $session->param('collectionY'));
}

sub getSelectedCollections
{
	my $session = shift;
	# array ref
	my $X_name = shift;
	my $Y_name = shift;
	
	my $collectionX;
	my $collectionY;
	
	my @mycollections = BeastSession::loadObjsFromSession($session, 'mycollections', Collection->new('constructor',""));	
	unless (ref($mycollections[0]) eq 'Collection') {
		return "";
	}

	foreach my $collection (@mycollections) {
		if ($X_name eq $collection->get_name) {
			$collectionX = $collection;	
		} elsif ($Y_name eq $collection->get_name) {
			$collectionY = $collection;	
		}
	}

	return ($collectionX, $collectionY);
}

sub loadSetsForActiveCollections
{
	my $session = shift;

	my ($X, $Y) = getSelectedCollectionNames($session);
	if (  (!$X || $X eq "") || (!$Y || $Y eq "")) {
		return "";
	}

	my ($collectionX, $collectionY) = getSelectedCollections($session, $X, $Y);
	if ($X eq $Y) {
		$collectionY = $collectionX;
	}

	if (  (!$collectionX || $collectionX eq "") || (!$collectionY || $collectionY eq "")) {
		return "";
	}
	my @collectionX_setNames = $collectionX->get_set_names;
	my @collectionY_setNames = $collectionY->get_set_names;

	my @setsX = loadMergeLeafSetsValues($session, 'mysets', \@collectionX_setNames, 1);

	my @setsY;
	if ($X eq $Y) {
		@setsY = @setsX;
	} else {
		@setsY = loadMergeLeafSetsValues($session, 'mysets', \@collectionY_setNames, 1);
	}

	return (\@setsX, \@setsY);	
}

sub mergeWithCheckbox
{
	my $sets_ref = shift;
	my $checked_hash = shift;

	die unless (ref($sets_ref) eq 'ARRAY');
	die unless (ref($checked_hash) eq 'HASH');

	my @selected_sets;
	#  merge with checkbox data
	# fixme: we somehow have to only move the checked subset
	my @sets = @$sets_ref;
	foreach my $set (@sets) {
		#my $set = $_;
		#my $name = $set->get_name;
		#if (exists $checked_hash->{$name}) {
			$set->mergeCheckbox_Simple($checked_hash);
			if ($set->pare_inactive_leaves > 0) {
				push @selected_sets, $set;
			}
		#}
	}

	return @selected_sets;
}

#
# Return: [ retval(0|1), @sets ]
#

sub loadObjsFromSession($$$)
{
	my $session = shift;
	my $key = shift;
	my $obj = shift;

	die unless (ref($session) eq 'CGI::Session');
	die unless ($key =~ /^\w+$/);

	my $objsstr = $session->param($key);	
	unless ($objsstr =~ /\S+/) { return 0; }
	my @lines = split (/:SEP:/, $objsstr);
	my @objs;
	foreach (@lines) {
		my $line = $_;
		next unless ($line =~ /_name/);
		push @objs, $obj->new($line);
	}

	unless (ref($objs[0])) {
		pop @objs;
	}

	return @objs;
}

sub checkMySetsNull($)
{
	my $session = shift;
	my @sets = loadObjsFromSession($session, 'mysets', Set->new('constructor', 1,"", ""));	
	unless (ref($sets[0]) eq 'Set') {
		pop @sets;
	}
	if (scalar(@sets) == 0) { return 0; }
	return 1;
}

sub loadImportSetsFromSession($)
{
	my $session = shift;

	my @sets = loadObjsFromSession($session, 'mysets', Set->new('constructor', 1,"", ""));	
	foreach (@sets) {
		my $set = $_;
		if ($set->get_name eq 'ImportSets') {
			return $set->get_elements;
		}
	}

	return undef;
}

sub loadLeafSetsFromSession
{
	my $session = shift;
	my $key = shift;
	# 1 yes, 0 no
	my $keep_inactive = shift;
	# 1 yes, 0 no
	my $include_elements = shift;
	my $entity_opts = shift || undef;

	## 
	##  We do have to get the entities from the DB at this point
	##
	my $beastDB = BeastDB->new;
	$beastDB->connectDB();

	my $uniq_leaves = {};
	
	my @sets = loadObjsFromSession($session, $key, Set->new('constructor', 1,"", ""));	
	unless (ref($sets[0]) eq 'Set') {
		pop @sets;
	}
	
	return unless (scalar(@sets) > 0); 
	foreach (@sets) {
		my $set = $_;
		my @set_leaves = $set->getLeafNodes();
		foreach (@set_leaves) {
			my $leaf = $_;

			# no duplicates		
			my $name = $leaf->get_name();
			next if (exists $uniq_leaves->{$name});

			# skip inactive elements, if directed to do so
			next if (($keep_inactive == 0) && ($leaf->is_active == 0));

			if ($include_elements == 1) {

				my $add_ext_id = undef;
				if (defined $entity_opts && exists $entity_opts->{'external_id'}) {
					$add_ext_id = 1;	
				}

				my $i = 0;
				my $elements_for_this_set = $beastDB->getEntitiesForSet($leaf->get_id);
				foreach my $el_name (keys %$elements_for_this_set) {

					# hashref with member_value, external_id
					my $element = $elements_for_this_set->{$el_name};

					# get the keyspace organism for the first entity, and use that
					# for the set metadata -- assuming homosets here
					if ($i == 0) {
						my $organism = $beastDB->getKeyspaceOrganism($element->{'id'});
						$i++;
						$leaf->set_metadata_value('organism', $organism);
					}

					#print Data::Dumper->Dump([$element]);
					if (defined $add_ext_id) {
						$leaf->set_element(uc($el_name),$element->{'external_id'});
					} else {
						$leaf->set_element(uc($el_name),"");
					}
				}
			}

			# get the sets_info source
			if (!$leaf->get_source) {
				my $source = $beastDB->getSetsInfoForSet($leaf->get_id, 'source');
				$leaf->set_source($source);
			}

			$uniq_leaves->{$name} = $leaf;
		}
	}

	$beastDB->disconnectDB();

	# sort on the unique internal database ID
	my @leaves;
	foreach (sort { $uniq_leaves->{$a}->{'_metadata'}->{'id'} <=> $uniq_leaves->{$b}->{'_metadata'}->{'id'} } keys %$uniq_leaves) {
		#print $_."<br>";
		push @leaves, $uniq_leaves->{$_};
	}
	return @leaves;
}

1;
