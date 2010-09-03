#!/usr/bin/perl -w
#Author:	Evan Paull (epaull@soe.ucsc.edu)
#Create Date:	6.16.2010

use strict;
use warnings;
use lib "/projects/sysbio/map/Projects/BEAST/perllib";
use Data::Dumper;
use BEAST::Set;
use BEAST::CheckBoxTree;
use BEAST::Constants;

package MySets;

sub updateActiveElements
{
	my $checkedHash = shift;
	my @sets = @_;
	
	my @selected_sets;
	#  merge with checkbox data
	# fixme: we somehow have to only move the checked subset
	foreach (@sets) {
		my $set = $_;
		my $name = $set->get_name;
		$set->mergeCheckbox_Simple($checkedHash);
	}
}


sub displaySetsTree
{
	my $divID = shift;
	# associative array ref
	my $selected = shift;
	my @sets = @_;

	my $displayData = {};

	foreach (@sets) {
		my $set = $_;
 		my $name = $set->get_name;

		$displayData->{$name} = getDisplayHash($set, $selected);
		$displayData->{$name}->{'_active'} = $set->{'_active'};
		$displayData->{$name}->{'_desc'} = $set->get_metadata_value('name');
		$displayData->{$name}->{'_type'} = $set->get_metadata_value('type');
		$displayData->{$name}->{'_id'} = $set->get_metadata_value('id');

		if (ref($selected) eq 'HASH' && exists $selected->{$name}) {
			$displayData->{$name}->{'_selected'} = 1;
		} else {
			$displayData->{$name}->{'_selected'} = 0;
		}
	}

	#print Data::Dumper->Dump([$displayData]);
	CheckBoxTree::buildCheckBoxTree($displayData, "", $divID);
}

sub displaySetsFlat
{
	my $divID = shift;
	my $selected = shift;
	my @sets = @_;


	displaySetsTree($divID, $selected, @sets);
}

sub getDisplayHash
{
	my $set = shift;
	my $selected = shift;

	my $displayData = {};

	my $setname = $set->get_name;
	my @element_names = $set->get_element_names;

	if ($element_names[0] eq "") { return {}};

	foreach (@element_names) {
		my $element_name = $_;	
		my $element = $set->get_element($element_name);
		# element is either a set object or a string null string

			
		if (ref($element) eq 'Set') {
			# element is a set -- add the sub-data hash to this 
			$displayData->{$element_name} = getDisplayHash($element, $selected);	
			$displayData->{$element_name}->{'_active'} = $element->{'_active'};

			## add metadata to display
			$displayData->{$element_name}->{'_desc'} = $element->get_metadata_value('name');
			$displayData->{$element_name}->{'_type'} = $element->get_metadata_value('type');
			$displayData->{$element_name}->{'_id'} = $element->get_metadata_value('id');
		
			if (ref($selected) eq 'HASH' && exists $selected->{$element_name}) {
				$displayData->{$element_name}->{'_selected'} = 1;
			} else {
				$displayData->{$element_name}->{'_selected'} = 0;
			}

		} else {
			# element is either 0 or 1 depending on whether it's active
			# do not add elements to the display -- slows things down
			#$displayData->{$element_name} = $element;
		}
	}

	return $displayData;
}

sub sortElementsList
{
	my @sets = @_;

	my $all_elements = {};
	foreach my $set (@sets) {
		foreach ($set->get_element_names) {
			if (exists $all_elements->{$_}) {
				$all_elements->{$_}++;
			} else {
				$all_elements->{$_} = 1;
			}
		}
	}

	return sort { $all_elements->{$a} <=> $all_elements->{$b} } keys %$all_elements;
}


1;
