#!/usr/bin/perl -w
#Author:	Evan Paull (epaull@soe.ucsc.edu)
#Create Date:	6.16.2010

use strict;
use warnings;
use lib "/projects/sysbio/map/Projects/BEAST/perllib";
use Data::Dumper;
use BEAST::Set;
use BEAST::CheckBoxTree;

package MySets;

#
# Apply checkbox updates to the active sets
#
sub updateActiveElements
{
	# hash ref 
	my $checkedHash = shift;
	my $sets = shift;

	foreach (@$sets)
	{
		my $set = $_;
		my $name = $set->get_name;	
		my $checked;
		if (exists $checkedHash->{$name}) {
			$checked = 1;
		} else {
			$checked = 0;
		}
		$set->{'_active'} = $checked;
		updateActive($checkedHash, $set, $set->get_name);
	}
}

sub updateActive 
{
	my $checkedHash = shift;
	my $set = shift;
	my $key = shift;
	
	my @element_names = $set->get_element_names;
	foreach (@element_names)
	{ 
		my $name = $_;
		my $element = $set->get_element($name);

		my $checked;
		if (exists $checkedHash->{$key.":".$name}) {
			$checked = 1;
		} else {
			$checked = 0;
		}

		if (ref($element) eq 'Set') {
			$element->{'_active'} = $checked;
			updateActive($checkedHash, $element, $key.":".$element->get_name);
		} else {
			#print "setting $name to $checked! with key: $key:$name<br>\n";
			$set->set_element($name, $checked);
		}
	}
}


sub displaySets
{
	my @sets = @_;

	my $displayData = {};

	foreach (@sets) {
		my $set = $_;
 		my $name = $set->get_name;

		$displayData->{$name} = getDisplayHash($set);
		$displayData->{$name}->{'_active'} = $set->{'_active'};
	}

	#print Data::Dumper->Dump([$displayData]);
	CheckBoxTree::buildCheckBoxTree($displayData, "");
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
		} else {
			# element is either 0 or 1 depending on whether it's active
			$displayData->{$element_name} = $element;
		}
	}

	return $displayData;
}

1;
