#!/usr/bin/perl -w
#Author:	Evan Paull (epaull@soe.ucsc.edu)
#Create Date:	6.15.2010

package CheckBoxTree;

use strict;
use warnings;
use lib "/projects/sysbio/map/Projects/BEAST/perllib";
use htmlHelper;

sub buildCheckBoxTree($$);

###
### Build drop down list below this item
###
sub buildCheckBoxTree($$)
{
	my $dataRef = shift;
	my $key = shift;

	die "$dataRef not a hash ref!" unless (ref $dataRef eq 'HASH');
	my @keys;

	my $marginleft = "margin-left:20px;";

	unless ($key eq "") {
		$keys[0] = $key;
		if ($key =~ /:/) {
			@keys = split(/:/,$key);
			$marginleft = "margin-left:".(($#keys+2)*10)."px;";
		}
	}

	# dig down through the keys supplied, updating the reference through each
	my $ref = $dataRef;
	foreach (@keys) {
		$ref = $ref->{$_};	
	}

	unless ($key eq "") {
	  htmlHelper::beginTreeSection($key, 'FALSE');
	}

	my @list;

	if ($key eq "") { 
		# in this case we're starting at the top of the hash -- key is blank
		@list = keys %{$ref}; 
	} else {
		if (ref($ref) eq 'HASH') {
			@list = keys %$ref;
		} elsif (ref($ref) eq 'ARRAY') {
			@list = @{$ref};
		} elsif (ref($ref) eq 'SCALAR') {
			$list[0] = $ref;
		} else {
			die "Improper data type!";
		}
	}

	foreach (@list) { 

		my $name = $_;

		if (ref($ref) eq 'HASH') {
			## print another drop-down arrow, which includes a checkbox for 
			## this element as well
			my $index = ($key eq "") ? $name : "$key:$name";
			buildCheckBoxTree($dataRef, $index); 
		} else {
			## print the tag and move on
			print "<input style='$marginleft' type=checkbox name=\"";
			($key eq "") ? print $name : print "$key:$name";
			print "\">$name<br/>\n";
		}

	}
	unless ($key eq "") {
	  htmlHelper::endSection($key);
	}
}

1;
