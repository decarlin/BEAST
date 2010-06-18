#!/usr/bin/perl -w
#Author:	Evan Paull (epaull@soe.ucsc.edu)
#Create Date:	6.16.2010

use strict;
use warnings;
use lib "/projects/sysbio/map/Projects/BEAST/perllib";
use BEAST::Set;
use BEAST::CheckBoxTree;

package MySets;

sub display_my_sets
{
	my @sets = @_;

	my $displayData = {};

	foreach (@sets) {
		my $set = $_;
		my $name = $set->get_name;
		my @element_names = $set->get_element_names;
		$displayData->{$name} = [ @element_names ];
	}

	CheckBoxTree::buildCheckBoxTree($displayData, "");
}

1;
