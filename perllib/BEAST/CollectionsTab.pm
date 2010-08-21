#!/usr/bin/perl -w
#Author:	Evan Paull (epaull@soe.ucsc.edu)
#Create Date:	6.16.2010

use strict;
use warnings;
use lib "/projects/sysbio/map/Projects/BEAST/perllib";
use Data::Dumper;
use BEAST::Collection;
use BEAST::CheckBoxTree;
use BEAST::Constants;

package CollectionsTab;


sub new
{
	my $class = shift;
	my $self = {
		_input 		=> shift,
	};

	bless $self, $class;
	return $self;
}

sub printTab
{
	# hash ref to the input form data
	my $self = shift;
	my $session = shift || undef;

	if (defined $session) {
		die unless (ref($session) eq 'CGI::Session');
	}

	# get active mysets objects
	my @mycollections = BeastSession::loadObjsFromSession($session, 'mycollections', Set->new('constructor', 1,"", ""));	
	unless (ref($mycollections[0]) eq 'Collection') {
		pop @mycollections;
	}
	return unless (scalar(@mycollections) > 0); 


	my @mysets = BeastSession::loadObjsFromSession($session, 'mysets', Set->new('constructor', 1,"", ""));	
	unless (ref($mysets[0]) eq 'Set') {
		pop @mysets;
	}
	return unless (scalar(@mysets) > 0); 
	
	print "<div><b>Add New Collection:</b></div>";
	print "<input type='button' name='add_collection' value='Add To Collections' onClick='return onAddCollection();'>";
	MySets::displaySetsTree("new_collection", "", @mysets);
}


1;
