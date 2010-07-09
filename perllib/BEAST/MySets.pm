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
		if (exists $checkedHash->{$name}) {
			$set->mergeCheckbox_Inactivate($checkedHash);
			push @selected_sets, $set;
		}
	}

	return @selected_sets;
}


sub displaySets
{
	my $divID = shift;
	my @sets = @_;

	my $displayData = {};

	foreach (@sets) {
		my $set = $_;
 		my $name = $set->get_name;

		$displayData->{$name} = getDisplayHash($set);
		$displayData->{$name}->{'_active'} = $set->{'_active'};
		$displayData->{$name}->{'_desc'} = $set->get_metadata_value('name');
		$displayData->{$name}->{'_type'} = $set->get_metadata_value('type');
		$displayData->{$name}->{'_id'} = $set->get_metadata_value('id');
	}

	#print Data::Dumper->Dump([$displayData]);
	CheckBoxTree::buildCheckBoxTree($displayData, "", $divID);
}

sub getDisplayHash
{
	my $set = shift;

	my $displayData = {};

	my $setname = $set->get_name;
	my @element_names = $set->get_element_names;

	foreach (@element_names) {
		my $element_name = $_;	
		my ($retval, $element) = $set->get_element($element_name);
		die "Can't retrieve element: $element_name! from $setname!" unless ($retval);
		# element is either a set object or a string null string

			
		if (ref($element) eq 'Set') {
			# element is a set -- add the sub-data hash to this 
			$displayData->{$element_name} = getDisplayHash($element);	
			$displayData->{$element_name}->{'_active'} = $element->{'_active'};

			## add metadata to display
			$displayData->{$element_name}->{'_desc'} = $element->get_metadata_value('name');
			$displayData->{$element_name}->{'_type'} = $element->get_metadata_value('type');
			$displayData->{$element_name}->{'_id'} = $element->get_metadata_value('id');
		
		} else {
			# element is either 0 or 1 depending on whether it's active
			$displayData->{$element_name} = $element;
		}
	}

	return $displayData;
}

1;
