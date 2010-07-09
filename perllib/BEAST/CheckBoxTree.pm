#!/usr/bin/perl -w
#Author:	Evan Paull (epaull@soe.ucsc.edu)
#Create Date:	6.15.2010

package CheckBoxTree;

use strict;
use warnings;
use lib "/projects/sysbio/map/Projects/BEAST/perllib";

use BEAST::Constants;
use htmlHelper;


our $delim = Constants::SET_NAME_DELIM;
###
### Build drop down list below this item
###
sub buildCheckBoxTree($$$)
{
	my $dataRef = shift;
	my $key = shift;
	my $divID = shift;

	die "$dataRef not a hash ref!" unless (ref $dataRef eq 'HASH');
	my @keys;

	my $marginleft = "margin-left:20px;"; 
	unless ($key eq "") {
		$keys[0] = $key;
		if ($key =~ /$delim/) {
			@keys = split(/$delim/,$key);
			$marginleft = "margin-left:".(($#keys+2)*10)."px;";
	  	}
	}

	# dig down through the keys supplied, updating the reference through each
	my $ref = $dataRef;
	foreach (@keys) {
		$ref = $ref->{$_};	
	}

	my $isActiveElement;

	my @list;

	if ($key eq "") { 
		# in this case we're starting at the top of the hash -- key is blank
		@list = keys %{$ref}; 
	} else {
		if (ref($ref) eq 'HASH') {
			@list = keys %$ref;
			# value is 1 or 0 depending on whether this set is active
			$isActiveElement = $ref->{'_active'};
		} elsif (!ref($ref)) {
			$list[0] = $ref;
		} else {
			die "Improper data type!";
		}
	}

	my $desc = "()";	
	if (exists $ref->{'_desc'}) {
		$desc = "(".$ref->{'_desc'}.")";
	}
	unless ($key eq "") {
	  htmlHelper::beginTreeSection($key, 'FALSE', $isActiveElement, $desc, $divID);
	}

	foreach (@list) { 

		my $name = $_;
		next if ($name eq '_active');

		if ( (ref($ref) eq 'HASH') && ref($ref->{$name}) ) {
			## print another drop-down arrow, which includes a checkbox for 
			## this element as well
			my $index = ($key eq "") ? $name : $key.Constants::SET_NAME_DELIM.$name;
			buildCheckBoxTree($dataRef, $index, $divID); 
		} elsif ($name =~ /_desc|_type|_id/) {
			next;
		} else {

			## determine if this element is checked or not
			my $checkedText;
			$isActiveElement = $ref->{$name};
			if ($isActiveElement == 1) {
				$checkedText = "checked";	
			} else {
				$checkedText = "";
			}

			## print the tag and move on
			print "<input style='$marginleft' type=checkbox name=\"";
			($key eq "") ? print $name : print $key.Constants::SET_NAME_DELIM.$name;
			print "\"$checkedText>$name<br/>\n";
		}

	}


	unless ($key eq "") {
	  htmlHelper::endSection($key);
	}
}

1;
