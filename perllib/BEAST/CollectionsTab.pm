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
	my @mycollections = BeastSession::loadObjsFromSession($session, 'mycollections', Collection->new('constructor',""));	
	unless (ref($mycollections[0]) eq 'Collection') {
		pop @mycollections;
	}

	if (scalar(@mycollections) > 0) {
	# collection X
		print <<MULTILINE_STR;
		<select name="Collections_X" id="collections_X"> 
MULTILINE_STR
		foreach (@mycollections) {
			my $name = $_->get_name;
			print "<option value=\"$name\">$name</option>";
		}
		print "</select>";
	
		# collectio Y
		print <<MULTILINE_STR;
		<select name="Collections_Y" id="collections_Y"> 
MULTILINE_STR
		foreach (@mycollections) {
			my $name = $_->get_name;
			print "<option value=\"$name\">$name</option>";
		}
		print "</select>";
	}

	my @mysets = BeastSession::loadObjsFromSession($session, 'mysets', Set->new('constructor', 1,"", ""));	
	unless (ref($mysets[0]) eq 'Set') {
		pop @mysets;
	}
	return unless (scalar(@mysets) > 0); 
	
	print "<div><b>Add New Collection:</b></div>";
	print "<form id=\"new_collection\">";
	print "<input type='text' id='add_collection_name' value='Collection Name'>";
	print "<input type='button' id='add_collection' value='Add To Collections' onClick='return onAddCollection(this.form);'>";
	MySets::displaySetsTree("new_collection", "", @mysets);
	print "</form>";
}


1;
